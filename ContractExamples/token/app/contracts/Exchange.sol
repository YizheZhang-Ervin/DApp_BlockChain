// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;
import '@openzeppelin/contracts/utils/math/SafeMath.sol';
import './MyToken.sol';

contract Exchange {
  // 扩展add和sub方法
  using SafeMath for uint256;
  // 收费账号地址
  address public feeAccount;
  // 费率
  uint256 public feePercent;
  address constant ETHER = address(0);
  mapping(address => mapping(address => uint256)) public tokens;
  mapping(uint256 => bool) public orderCancel;
  mapping(uint256 => bool) public orderFill;

  // 订单结构体
  struct _Order {
    uint id;
    address user;
    address tokenGet;
    uint256 amountGet;
    address tokenGive;
    uint256 amountGive;
    uint256 timestamp;
  }

  // _Order[] orderList;
  mapping(uint256 => _Order) public orders;
  uint256 public orderCount;

  constructor(address _feeAccount, uint256 _feePercent) {
    feeAccount = _feeAccount;
    feePercent = _feePercent;
  }

  event Deposit(address token, address user, uint256 amount, uint balance);

  event Withdraw(address token, address user, uint256 amount, uint256 balance);

  event Order(
    uint256 id,
    address user,
    address tokenGet,
    uint256 amountGet,
    address tokenGive,
    uint256 amountGive,
    uint256 timestamp
  );

  event Cancel(
    uint256 id,
    address user,
    address tokenGet,
    uint256 amountGet,
    address tokenGive,
    uint256 amountGive,
    uint256 timestamp
  );

  event Trade(
    uint256 id,
    address user,
    address tokenGet,
    uint256 amountGet,
    address tokenGive,
    uint256 amountGive,
    uint256 timestamp
  );

  // 存以太币
  function depositEther() public payable {
    // msg.sender
    // msg.value
    tokens[ETHER][msg.sender] = tokens[ETHER][msg.sender].add(msg.value);
    emit Deposit(ETHER, msg.sender, msg.value, tokens[ETHER][msg.sender]);
  }

  // 存自定义货币
  function depositToken(address _token, uint256 _amount) public {
    // 调用方法从账号向当前交易所转钱
    require(_token != ETHER);
    require(MyToken(_token).transferFrom(msg.sender, address(this), _amount));
    tokens[_token][msg.sender] = tokens[_token][msg.sender].add(_amount);
    emit Deposit(_token, msg.sender, _amount, tokens[_token][msg.sender]);
  }

  // 提取以太币
  function withdrawEther(uint256 _amount) public {
    require(tokens[ETHER][msg.sender] >= _amount);
    tokens[ETHER][msg.sender] = tokens[ETHER][msg.sender].sub(_amount);
    // 转钱给sender
    payable(msg.sender).transfer(_amount);
    emit Withdraw(ETHER, msg.sender, _amount, tokens[ETHER][msg.sender]);
  }

  // 提取自定义货币
  function withdrawToken(address _token, uint256 _amount) public {
    require(_token != ETHER);
    require(tokens[_token][msg.sender] >= _amount);
    tokens[_token][msg.sender] = tokens[_token][msg.sender].sub(_amount);
    // 当前合约给sender转钱
    require(MyToken(_token).transfer(msg.sender, _amount));
    emit Withdraw(_token, msg.sender, _amount, tokens[_token][msg.sender]);
  }

  // 余额查询
  function balanceOf(address _token, address _user) public view returns (uint256) {
    return tokens[_token][_user];
  }

  // make order
  function makeOrder(
    address _tokenGet,
    uint256 _amountGet,
    address _tokenGive,
    uint256 _amountGive
  ) public {
    require(balanceOf(_tokenGive, msg.sender) >= _amountGive, unicode'创订单的余额不足');
    orderCount = orderCount.add(1);
    orders[orderCount] = _Order(
      orderCount,
      msg.sender,
      _tokenGet,
      _amountGet,
      _tokenGive,
      _amountGive,
      block.timestamp
    );
    // 发出订单
    emit Order(
      orderCount,
      msg.sender,
      _tokenGet,
      _amountGet,
      _tokenGive,
      _amountGive,
      block.timestamp
    );
  }

  // cancel order
  function cancelOrder(uint256 _id) public {
    _Order memory myorder = orders[_id];
    require(myorder.id == _id);
    orderCancel[_id] = true;
    emit Cancel(
      myorder.id,
      msg.sender,
      myorder.tokenGet,
      myorder.amountGet,
      myorder.tokenGive,
      myorder.amountGive,
      block.timestamp
    );
  }

  // fill order 提交交易订单
  function fillOrder(uint256 _id) public {
    _Order memory myorder = orders[_id];
    require(myorder.id == _id);
    // 账户余额互换 & 小费收取
    // 计算小费
    uint256 feeAmount = myorder.amountGet.mul(feePercent).div(100);

    require(
      balanceOf(myorder.tokenGive, myorder.user) >= myorder.amountGive,
      unicode'以太币余额不足'
    );
    require(
      balanceOf(myorder.tokenGet, msg.sender) >= myorder.amountGet.add(feeAmount),
      unicode'填充订单的用户余额不足'
    );

    tokens[myorder.tokenGet][msg.sender] = tokens[myorder.tokenGet][msg.sender].sub(
      myorder.amountGet.add(feeAmount)
    );

    // 加小费
    tokens[myorder.tokenGet][feeAccount] = tokens[myorder.tokenGet][feeAccount].add(feeAmount);

    tokens[myorder.tokenGet][myorder.user] = tokens[myorder.tokenGet][myorder.user].add(
      myorder.amountGet
    );

    tokens[myorder.tokenGive][msg.sender] = tokens[myorder.tokenGive][msg.sender].add(
      myorder.amountGive
    );
    tokens[myorder.tokenGive][myorder.user] = tokens[myorder.tokenGive][myorder.user].sub(
      myorder.amountGive
    );

    orderFill[_id] = true;

    emit Trade(
      myorder.id,
      myorder.user,
      myorder.tokenGet,
      myorder.amountGet,
      myorder.tokenGive,
      myorder.amountGive,
      block.timestamp
    );
  }
}
