// Layout of Contract:
// version
// imports
// errors
// interfaces, libraries, contracts
// Type declarations
// State variables
// Events
// Modifiers
// Functions

// Layout of Functions:
// constructor
// receive function (if exists)
// fallback function (if exists)
// external
// public
// internal
// private
// internal & private view & pure functions
// external & public view & pure functions

// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

// 导入Oracle工具库（处理Chainlink价格喂价）和价格喂价接口
import {OracleLib, AggregatorV3Interface} from "./libraries/OracleLib.sol";
// 导入OpenZeppelin的重入锁库，防止重入攻击（如递归调用导致的资产被盗）
import {ReentrancyGuard} from "@openzeppelin/contracts/security/ReentrancyGuard.sol";
// 导入ERC20标准接口，用于与抵押品代币（如WETH、WBTC）交互
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
// 导入去中心化稳定币合约接口，用于铸造/销毁DSC
import {DecentralizedStableCoin} from "./DecentralizedStableCoin.sol";

/*
 * @title DSCEngine
 * @author Patrick Collins
 *
 * 系统设计目标：极简架构，确保稳定币始终维持1代币 = 1美元的锚定。
 * 稳定币属性：
 * - 外部抵押（依赖WETH、WBTC等外部资产抵押，非算法凭空生成）
 * - 美元锚定（价值与美元挂钩）
 * - 算法稳定（通过清算、健康因子等规则自动维持稳定，无需中心化治理）
 *
 * 功能类似MakerDAO的DAI，但无治理机制、无手续费，且仅支持WETH和WBTC作为抵押品。
 *
 * 核心规则：系统始终保持“超额抵押”，任何时刻所有抵押品的总价值 ≥ 所有已铸造DSC的美元总价值。
 *
 * @notice 本合约是去中心化稳定币系统的核心，处理DSC的铸造/销毁、抵押品的存入/提取逻辑。
 * @notice 合约设计基于MakerDAO的DSS（Decentralized Stablecoin System）系统。
 */
// 继承ReentrancyGuard以启用重入保护（关键函数需加nonReentrant修饰符）
contract DSCEngine is ReentrancyGuard {
    ///////////////////
    // 错误定义（自定义错误，相比require更省gas，且支持参数传递以便调试）
    ///////////////////
    // 抵押品代币地址数组与价格喂价地址数组长度不匹配（初始化时校验）
    error DSCEngine__TokenAddressesAndPriceFeedAddressesAmountsDontMatch();
    // 输入金额为0（如存入抵押品、铸造DSC时金额不能为0）
    error DSCEngine__NeedsMoreThanZero();
    // 抵押品代币不被允许（未在初始化时配置对应的价格喂价）
    error DSCEngine__TokenNotAllowed(address token);
    // 代币转账失败（如抵押品存入时用户未授权、合约余额不足等）
    error DSCEngine__TransferFailed();
    // 健康因子跌破阈值（用户抵押品不足以覆盖债务，需补充抵押品或偿还债务）
    error DSCEngine__BreaksHealthFactor(uint256 healthFactorValue);
    // DSC铸造失败（调用DecentralizedStableCoin合约的mint函数返回false）
    error DSCEngine__MintFailed();
    // 健康因子正常（清算时目标用户健康因子未跌破阈值，无需清算）
    error DSCEngine__HealthFactorOk();
    // 健康因子未改善（清算后用户健康因子未提升，可能清算逻辑异常）
    error DSCEngine__HealthFactorNotImproved();

    ///////////////////
    // 类型扩展（使用OracleLib库的函数，为AggregatorV3Interface添加额外方法）
    ///////////////////
    // 让AggregatorV3Interface类型的变量可直接调用OracleLib中的函数（如staleCheckLatestRoundData）
    using OracleLib for AggregatorV3Interface;

    ///////////////////
    // 状态变量（核心数据存储，记录系统状态）
    ///////////////////
    // 去中心化稳定币合约实例（不可变，初始化后固定）
    DecentralizedStableCoin private immutable i_dsc;

    // 清算阈值：50（即抵押品价值需达到债务的200%，1/0.5=2倍超额抵押）
    uint256 private constant LIQUIDATION_THRESHOLD = 50;
    // 清算奖励：10（清算者可获得10%的抵押品奖励，鼓励用户参与清算以维持系统稳定）
    uint256 private constant LIQUIDATION_BONUS = 10;
    // 清算精度：100（用于百分比计算，如LIQUIDATION_THRESHOLD/LIQUIDATION_PRECISION = 50%）
    uint256 private constant LIQUIDATION_PRECISION = 100;
    // 最低健康因子：1e18（健康因子低于此值将触发清算，1e18对应1.0，因使用18位精度）
    uint256 private constant MIN_HEALTH_FACTOR = 1e18;
    // 通用精度：1e18（处理代币金额时的精度，适配大多数ERC20代币的18位小数）
    uint256 private constant PRECISION = 1e18;
    // 额外价格精度：1e10（Chainlink价格喂价返回8位小数，乘以1e10后转为18位精度，与PRECISION对齐）
    uint256 private constant ADDITIONAL_FEED_PRECISION = 1e10;
    // 价格喂价精度：1e8（Chainlink USD类价格喂价的默认精度，如1 ETH = 2000 USD会返回2000 * 1e8）
    uint256 private constant FEED_PRECISION = 1e8;

    /// @dev 抵押品代币地址 → 对应价格喂价地址的映射（记录每个抵押品的价格来源）
    mapping(address collateralToken => address priceFeed) private s_priceFeeds;
    /// @dev 用户地址 → 抵押品代币地址 → 存入金额的映射（记录每个用户的抵押品持仓）
    mapping(address user => mapping(address collateralToken => uint256 amount))
        private s_collateralDeposited;
    /// @dev 用户地址 → 已铸造DSC金额的映射（记录每个用户的债务）
    mapping(address user => uint256 amount) private s_DSCMinted;
    /// @dev 允许的抵押品代币列表（遍历用户所有抵押品时使用，避免遍历整个映射）
    address[] private s_collateralTokens;

    ///////////////////
    // 事件定义（记录关键操作，方便前端追踪和链上数据分析）
    ///////////////////
    // 抵押品存入事件：记录存入用户、抵押品代币、存入金额
    event CollateralDeposited(
        address indexed user,
        address indexed token,
        uint256 indexed amount
    );
    // 抵押品提取事件：记录提取来源（用户本人或被清算的用户）、提取接收者、抵押品代币、提取金额
    event CollateralRedeemed(
        address indexed redeemFrom,
        address indexed redeemTo,
        address token,
        uint256 amount
    );

    ///////////////////
    // 修饰符（复用代码逻辑，确保关键条件在函数执行前被校验）
    ///////////////////
    // 校验输入金额是否大于0（如存入抵押品、铸造DSC时必用）
    modifier moreThanZero(uint256 amount) {
        if (amount == 0) {
            revert DSCEngine__NeedsMoreThanZero();
        }
        _; // 执行函数主体
    }

    // 校验抵押品代币是否被允许（即是否在s_priceFeeds中配置了价格喂价）
    modifier isAllowedToken(address token) {
        if (s_priceFeeds[token] == address(0)) {
            // 未配置价格喂价的代币视为不允许
            revert DSCEngine__TokenNotAllowed(token);
        }
        _; // 执行函数主体
    }

    ///////////////////
    // 核心函数（构造函数、外部函数、公共函数、私有函数）
    ///////////////////
    /**
     * @dev 合约构造函数（仅在部署时执行一次，初始化系统核心参数）
     * @param tokenAddresses 允许的抵押品代币地址数组（如[WETH地址, WBTC地址]）
     * @param priceFeedAddresses 对应抵押品的Chainlink价格喂价地址数组（需与tokenAddresses长度一致）
     * @param dscAddress 去中心化稳定币（DSC）合约的地址
     */
    constructor(
        address[] memory tokenAddresses,
        address[] memory priceFeedAddresses,
        address dscAddress
    ) {
        // 校验抵押品数组与价格喂价数组长度一致（避免配置错误）
        if (tokenAddresses.length != priceFeedAddresses.length) {
            revert DSCEngine__TokenAddressesAndPriceFeedAddressesAmountsDontMatch();
        }
        // 遍历数组，初始化抵押品-价格喂价映射和抵押品列表
        for (uint256 i = 0; i < tokenAddresses.length; i++) {
            s_priceFeeds[tokenAddresses[i]] = priceFeedAddresses[i];
            s_collateralTokens.push(tokenAddresses[i]);
        }
        // 初始化DSC合约实例（不可变变量需在构造函数中赋值）
        i_dsc = DecentralizedStableCoin(dscAddress);
    }

    ///////////////////
    // 外部函数（供外部用户调用，处理核心业务逻辑）
    ///////////////////
    /*
     * @notice 一站式操作：存入抵押品并铸造DSC（合并两个步骤，减少用户交易次数）
     * @param tokenCollateralAddress 抵押品代币地址（需在允许列表中）
     * @param amountCollateral 存入的抵押品金额（需大于0）
     * @param amountDscToMint 要铸造的DSC金额（需大于0，且铸造后健康因子不跌破阈值）
     */
    function depositCollateralAndMintDsc(
        address tokenCollateralAddress,
        uint256 amountCollateral,
        uint256 amountDscToMint
    ) external {
        // 先存入抵押品（会触发权限和金额校验）
        depositCollateral(tokenCollateralAddress, amountCollateral);
        // 再铸造DSC（会校验健康因子）
        mintDsc(amountDscToMint);
    }

    /*
     * @notice 一站式操作：提取抵押品并销毁DSC（偿还债务并取回抵押品，合并两个步骤）
     * @param tokenCollateralAddress 要提取的抵押品代币地址（需在允许列表中）
     * @param amountCollateral 要提取的抵押品金额（需大于0）
     * @param amountDscToBurn 要销毁的DSC金额（需大于0，用于偿还债务）
     */
    function redeemCollateralForDsc(
        address tokenCollateralAddress,
        uint256 amountCollateral,
        uint256 amountDscToBurn
    )
        external
        moreThanZero(amountCollateral) // 校验提取金额大于0
        isAllowedToken(tokenCollateralAddress) // 校验抵押品合法
    {
        // 1. 先销毁DSC（偿还债务，减少用户的DSC持仓）
        _burnDsc(amountDscToBurn, msg.sender, msg.sender);
        // 2. 再提取抵押品（从用户自己的抵押品中提取，转入用户地址）
        _redeemCollateral(
            tokenCollateralAddress,
            amountCollateral,
            msg.sender,
            msg.sender
        );
        // 3. 校验提取后健康因子是否正常（防止提取后抵押品不足）
        _revertIfHealthFactorIsBroken(msg.sender);
    }

    /*
     * @notice 提取抵押品（仅在用户无未偿还DSC债务时可用，或提取后健康因子仍正常）
     * @param tokenCollateralAddress 要提取的抵押品代币地址（需在允许列表中）
     * @param amountCollateral 要提取的抵押品金额（需大于0）
     */
    function redeemCollateral(
        address tokenCollateralAddress,
        uint256 amountCollateral
    )
        external
        moreThanZero(amountCollateral) // 校验提取金额大于0
        nonReentrant // 重入保护（防止递归调用导致的抵押品重复提取）
        isAllowedToken(tokenCollateralAddress) // 校验抵押品合法
    {
        // 提取抵押品（从用户自己的抵押品中提取，转入用户地址）
        _redeemCollateral(
            tokenCollateralAddress,
            amountCollateral,
            msg.sender,
            msg.sender
        );
        // 校验提取后健康因子是否正常（防止提取后抵押品不足）
        _revertIfHealthFactorIsBroken(msg.sender);
    }

    /*
     * @notice 销毁DSC（主动偿还债务，可提升健康因子，避免被清算）
     * @dev 适用于用户担心健康因子过低时，主动销毁DSC以降低债务
     * @param amount 要销毁的DSC金额（需大于0）
     */
    function burnDsc(uint256 amount) external moreThanZero(amount) {
        // 销毁DSC（从用户地址扣减DSC，销毁后减少用户债务）
        _burnDsc(amount, msg.sender, msg.sender);
        // 校验销毁后健康因子是否正常（理论上销毁债务会提升健康因子，此校验为兜底）
        _revertIfHealthFactorIsBroken(msg.sender);
    }

    /*
     * @notice 清算功能（当用户健康因子跌破阈值时，其他用户可参与清算以维持系统稳定）
     * @param collateral 要清算的抵押品代币地址（需在允许列表中）
     * @param user 被清算的用户地址（需健康因子低于MIN_HEALTH_FACTOR）
     * @param debtToCover 要覆盖的债务金额（即清算者愿意销毁的DSC金额，用于偿还被清算者的债务）
     *
     * @notice 清算规则：
     * 1. 可部分清算（无需清算用户全部债务）
     * 2. 清算者获得10%的抵押品奖励（以折扣价获取抵押品，激励清算行为）
     * 3. 系统需维持约150%的超额抵押，否则清算逻辑可能失效（如抵押品价格暴跌至仅100%抵押）
     * @notice 已知风险：若抵押品价格瞬间暴跌至100%抵押，将无法清算任何用户，系统可能暂时不稳定
     */
    function liquidate(
        address collateral,
        address user,
        uint256 debtToCover
    )
        external
        isAllowedToken(collateral) // 校验抵押品合法
        moreThanZero(debtToCover) // 校验覆盖债务金额大于0
        nonReentrant // 重入保护（防止递归清算导致的资产异常）
    {
        // 1. 校验被清算用户的初始健康因子（必须低于阈值才允许清算）
        uint256 startingUserHealthFactor = _healthFactor(user);
        if (startingUserHealthFactor >= MIN_HEALTH_FACTOR) {
            revert DSCEngine__HealthFactorOk();
        }

        // 2. 计算覆盖债务所需的抵押品数量（按当前价格换算）
        // 例：覆盖100 DSC债务，需对应100美元价值的抵押品
        uint256 tokenAmountFromDebtCovered = getTokenAmountFromUsd(
            collateral,
            debtToCover
        );
        // 3. 计算清算奖励（10%额外抵押品）
        // 例：覆盖100美元债务，清算者可获得110美元价值的抵押品（10%奖励）
        uint256 bonusCollateral = (tokenAmountFromDebtCovered *
            LIQUIDATION_BONUS) / LIQUIDATION_PRECISION;

        // 4. 执行清算：从被清算用户处提取抵押品，转入清算者地址（含奖励）
        _redeemCollateral(
            collateral,
            tokenAmountFromDebtCovered + bonusCollateral,
            user,
            msg.sender
        );
        // 5. 销毁清算者的DSC（用于偿还被清算用户的债务）
        _burnDsc(debtToCover, user, msg.sender);

        // 6. 校验清算后被清算用户的健康因子（必须提升，确保清算有效）
        uint256 endingUserHealthFactor = _healthFactor(user);
        if (endingUserHealthFactor <= startingUserHealthFactor) {
            revert DSCEngine__HealthFactorNotImproved();
        }

        // 7. 校验清算者自身的健康因子（防止清算后清算者自己健康因子跌破阈值）
        _revertIfHealthFactorIsBroken(msg.sender);
    }

    // ##############################
    // 公共函数（Public Functions）：外部可调用，也可被合约内部调用
    // ##############################
    /*
     * @param amountDscToMint: 要铸造的DSC数量
     * 只有当你拥有足够抵押品时，才能铸造DSC
     */
    // 铸造DSC函数：参数为铸造数量，修饰符确保数量>0、防止重入
    function mintDsc(
        uint256 amountDscToMint
    ) public moreThanZero(amountDscToMint) nonReentrant {
        // 更新用户的DSC铸造记录（增加用户债务）
        s_DSCMinted[msg.sender] += amountDscToMint;
        // 校验铸造后用户健康因子是否达标，不达标则回滚
        _revertIfHealthFactorIsBroken(msg.sender);
        // 调用DSC合约的mint函数，向用户地址铸造指定数量DSC，返回铸造结果
        bool minted = i_dsc.mint(msg.sender, amountDscToMint);

        // 若铸造结果为false（铸造失败），触发自定义错误
        if (minted != true) {
            revert DSCEngine__MintFailed();
        }
    }

    /*
     * @param tokenCollateralAddress: 要存入的抵押品ERC20代币地址
     * @param amountCollateral: 要存入的抵押品数量
     */
    // 存入抵押品函数：参数为抵押品地址和数量，修饰符确保数量>0、防止重入、抵押品合法
    function depositCollateral(
        address tokenCollateralAddress,
        uint256 amountCollateral
    )
        public
        moreThanZero(amountCollateral)
        nonReentrant
        isAllowedToken(tokenCollateralAddress)
    {
        // 更新用户的抵押品存入记录（增加用户该代币的抵押量）
        s_collateralDeposited[msg.sender][
            tokenCollateralAddress
        ] += amountCollateral;
        // 触发抵押品存入事件，记录用户、抵押品地址、数量（方便链下追踪）
        emit CollateralDeposited(
            msg.sender,
            tokenCollateralAddress,
            amountCollateral
        );
        // 调用ERC20的transferFrom，从用户地址向合约转入抵押品，返回转账结果
        bool success = IERC20(tokenCollateralAddress).transferFrom(
            msg.sender,
            address(this),
            amountCollateral
        );
        // 若转账结果为false（转账失败），触发自定义错误
        if (!success) {
            revert DSCEngine__TransferFailed();
        }
    }

    // ##############################
    // 私有函数（Private Functions）：仅合约内部可调用，封装核心逻辑
    // ##############################
    // 提取抵押品内部函数：参数为抵押品地址、数量、提取来源地址、接收地址
    function _redeemCollateral(
        address tokenCollateralAddress,
        uint256 amountCollateral,
        address from,
        address to
    ) private {
        // 减少来源地址（from）的抵押品记录
        s_collateralDeposited[from][tokenCollateralAddress] -= amountCollateral;
        // 触发抵押品提取事件，记录来源、接收者、抵押品地址、数量
        emit CollateralRedeemed(
            from,
            to,
            tokenCollateralAddress,
            amountCollateral
        );
        // 调用ERC20的transfer，从合约向接收地址（to）转入抵押品，返回转账结果
        bool success = IERC20(tokenCollateralAddress).transfer(
            to,
            amountCollateral
        );
        // 若转账失败，触发自定义错误
        if (!success) {
            revert DSCEngine__TransferFailed();
        }
    }

    // 销毁DSC内部函数：参数为销毁数量、债务归属者、DSC来源地址
    function _burnDsc(
        uint256 amountDscToBurn,
        address onBehalfOf,
        address dscFrom
    ) private {
        // 减少债务归属者（onBehalfOf）的DSC债务记录
        s_DSCMinted[onBehalfOf] -= amountDscToBurn;

        // 调用ERC20的transferFrom，从DSC来源地址（dscFrom）向合约转入DSC，返回转账结果
        bool success = i_dsc.transferFrom(
            dscFrom,
            address(this),
            amountDscToBurn
        );
        // 注释：理论上此条件不会触发（因调用前会校验授权），仅作为安全兜底
        if (!success) {
            revert DSCEngine__TransferFailed();
        }
        // 调用DSC合约的burn函数，销毁合约内指定数量的DSC
        i_dsc.burn(amountDscToBurn);
    }

    // ##############################
    // 私有&内部视图函数（View/Pure）：仅读取状态/计算，不修改状态，可内部调用
    // ##############################

    // 获取用户账户核心信息：参数为用户地址，返回用户总铸造DSC（债务）和抵押品总美元价值
    function _getAccountInformation(
        address user
    )
        private
        view
        returns (uint256 totalDscMinted, uint256 collateralValueInUsd)
    {
        // 从状态变量读取用户总铸造DSC数量
        totalDscMinted = s_DSCMinted[user];
        // 调用函数计算用户所有抵押品的总美元价值
        collateralValueInUsd = getAccountCollateralValue(user);
    }

    // 计算用户健康因子：参数为用户地址，返回健康因子数值
    function _healthFactor(address user) private view returns (uint256) {
        // 获取用户债务和抵押品价值
        (
            uint256 totalDscMinted,
            uint256 collateralValueInUsd
        ) = _getAccountInformation(user);
        // 调用内部函数计算健康因子并返回
        return _calculateHealthFactor(totalDscMinted, collateralValueInUsd);
    }

    // 计算代币美元价值：参数为代币地址和数量，返回该数量代币的美元价值（1e18精度）
    function _getUsdValue(
        address token,
        uint256 amount
    ) private view returns (uint256) {
        // 根据代币地址获取对应的Chainlink价格喂价合约
        AggregatorV3Interface priceFeed = AggregatorV3Interface(
            s_priceFeeds[token]
        );
        // 调用OracleLib的staleCheckLatestRoundData，获取最新价格（带过期检查），忽略其他返回值
        (, int256 price, , , ) = priceFeed.staleCheckLatestRoundData();
        // 注释：示例：1 ETH = 1000 USD，Chainlink返回值为1000 * 1e8（8位小数）
        // 注释：大部分USD价格喂价都是8位小数，此处统一按8位处理
        // 注释：需将价格转换为1e18精度（与WEI对齐），故乘以1e10（ADDITIONAL_FEED_PRECISION）
        // 计算逻辑：(价格*精度转换) * 代币数量 / 1e18（PRECISION）→ 得到美元价值
        return
            ((uint256(price) * ADDITIONAL_FEED_PRECISION) * amount) / PRECISION;
    }

    // 计算健康因子核心公式：参数为总债务、抵押品总美元价值，返回健康因子
    function _calculateHealthFactor(
        uint256 totalDscMinted,
        uint256 collateralValueInUsd
    ) internal pure returns (uint256) {
        // 若用户无债务（总铸造DSC为0），健康因子设为uint256最大值（视为无风险）
        if (totalDscMinted == 0) return type(uint256).max;
        // 计算经清算阈值调整后的抵押品价值：抵押品价值 * 阈值 / 100（LIQUIDATION_PRECISION）
        uint256 collateralAdjustedForThreshold = (collateralValueInUsd *
            LIQUIDATION_THRESHOLD) / LIQUIDATION_PRECISION;
        // 计算健康因子：(调整后抵押品价值 * 1e18) / 总债务 → 确保1e18精度
        return (collateralAdjustedForThreshold * PRECISION) / totalDscMinted;
    }

    // 校验健康因子：参数为用户地址，若健康因子低于最小值则回滚
    function _revertIfHealthFactorIsBroken(address user) internal view {
        // 计算用户当前健康因子
        uint256 userHealthFactor = _healthFactor(user);
        // 若健康因子 < 最低健康因子（MIN_HEALTH_FACTOR），触发错误并返回当前健康因子
        if (userHealthFactor < MIN_HEALTH_FACTOR) {
            revert DSCEngine__BreaksHealthFactor(userHealthFactor);
        }
    }

    // ##############################
    // 外部&公共视图函数（View/Pure）：外部可调用，仅读取状态/计算，用于查询信息
    // ##############################

    // 外部计算健康因子接口：参数为总债务、抵押品价值，返回健康因子（复用内部逻辑）
    function calculateHealthFactor(
        uint256 totalDscMinted,
        uint256 collateralValueInUsd
    ) external pure returns (uint256) {
        // 调用内部健康因子计算函数并返回
        return _calculateHealthFactor(totalDscMinted, collateralValueInUsd);
    }

    // 外部获取账户信息接口：参数为用户地址，返回用户债务和抵押品价值（复用内部逻辑）
    function getAccountInformation(
        address user
    )
        external
        view
        returns (uint256 totalDscMinted, uint256 collateralValueInUsd)
    {
        // 调用内部账户信息函数并返回
        return _getAccountInformation(user);
    }

    // 外部获取代币美元价值接口：参数为代币地址和数量（WEI单位），返回美元价值（复用内部逻辑）
    function getUsdValue(
        address token,
        uint256 amount // in WEI：注释说明数量单位为WEI
    ) external view returns (uint256) {
        // 调用内部代币价值计算函数并返回
        return _getUsdValue(token, amount);
    }

    // 查询用户抵押品余额：参数为用户地址和代币地址，返回用户该代币的抵押数量
    function getCollateralBalanceOfUser(
        address user,
        address token
    ) external view returns (uint256) {
        // 从状态变量读取并返回用户该代币的抵押量
        return s_collateralDeposited[user][token];
    }

    // 计算用户抵押品总美元价值：参数为用户地址，返回总价值
    function getAccountCollateralValue(
        address user
    ) public view returns (uint256 totalCollateralValueInUsd) {
        // 遍历所有允许的抵押品代币列表
        for (uint256 index = 0; index < s_collateralTokens.length; index++) {
            // 获取当前遍历的抵押品代币地址
            address token = s_collateralTokens[index];
            // 读取用户该代币的抵押数量
            uint256 amount = s_collateralDeposited[user][token];
            // 累加该代币的美元价值到总价值中
            totalCollateralValueInUsd += _getUsdValue(token, amount);
        }
        // 返回用户所有抵押品的总美元价值
        return totalCollateralValueInUsd;
    }

    // 根据美元价值计算代币数量：参数为代币地址和美元价值（1e18精度），返回所需代币数量
    function getTokenAmountFromUsd(
        address token,
        uint256 usdAmountInWei
    ) public view returns (uint256) {
        // 获取该代币的Chainlink价格喂价合约
        AggregatorV3Interface priceFeed = AggregatorV3Interface(
            s_priceFeeds[token]
        );
        // 获取最新价格（带过期检查）
        (, int256 price, , , ) = priceFeed.staleCheckLatestRoundData();
        // 注释：示例：100e18 USD债务，1 ETH=2000 USD，Chainlink返回2000*1e8
        // 注释：大部分USD价格喂价为8位小数，统一按8位处理
        // 计算逻辑：(美元价值 * 1e18) / (价格 * 1e10) → 得到所需代币数量（WEI单位）
        return ((usdAmountInWei * PRECISION) /
            (uint256(price) * ADDITIONAL_FEED_PRECISION));
    }

    // 查询系统精度（PRECISION=1e18）：外部纯函数，返回精度值
    function getPrecision() external pure returns (uint256) {
        return PRECISION;
    }

    // 查询价格喂价额外精度（ADDITIONAL_FEED_PRECISION=1e10）：外部纯函数，返回精度值
    function getAdditionalFeedPrecision() external pure returns (uint256) {
        return ADDITIONAL_FEED_PRECISION;
    }

    // 查询清算阈值（LIQUIDATION_THRESHOLD=50）：外部纯函数，返回阈值
    function getLiquidationThreshold() external pure returns (uint256) {
        return LIQUIDATION_THRESHOLD;
    }

    // 查询清算奖励（LIQUIDATION_BONUS=10）：外部纯函数，返回奖励比例
    function getLiquidationBonus() external pure returns (uint256) {
        return LIQUIDATION_BONUS;
    }

    // 查询清算计算精度（LIQUIDATION_PRECISION=100）：外部纯函数，返回精度值
    function getLiquidationPrecision() external pure returns (uint256) {
        return LIQUIDATION_PRECISION;
    }

    // 查询最低健康因子（MIN_HEALTH_FACTOR=1e18）：外部纯函数，返回最小值
    function getMinHealthFactor() external pure returns (uint256) {
        return MIN_HEALTH_FACTOR;
    }

    // 查询允许的抵押品代币列表：外部视图函数，返回代币地址数组
    function getCollateralTokens() external view returns (address[] memory) {
        return s_collateralTokens;
    }

    // 查询DSC合约地址：外部视图函数，返回i_dsc的地址
    function getDsc() external view returns (address) {
        return address(i_dsc);
    }

    // 查询抵押品对应的价格喂价地址：参数为代币地址，返回喂价合约地址
    function getCollateralTokenPriceFeed(
        address token
    ) external view returns (address) {
        return s_priceFeeds[token];
    }

    // 查询用户健康因子：参数为用户地址，返回当前健康因子（复用内部逻辑）
    function getHealthFactor(address user) external view returns (uint256) {
        return _healthFactor(user);
    }
}
