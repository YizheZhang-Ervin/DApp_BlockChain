// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

// 乞丐版灾情众筹项目
contract CrowdFunding2 {
    // 发起人或者可以理解为需要被帮助的人
    struct needer {
        // 发起人钱包地址
        address payable neederAddress;
        // 发起人目标筹款金额
        uint goal;
        // 账户金额(已筹得金额)
        uint amount;
        // 捐款人个数
        uint funderAmount;
        // 捐款人id与捐款人映射
        mapping(uint => funder) map;
    }

    // 捐款人
    struct funder {
        // 捐款人账户地址
        address funderAddress;
        // 捐款金额
        uint money;
    }

    // 作为一个乞丐版的众筹平台 我们也不能只支持一个人在该平台上 发起众筹
    // 当多个人发起时，我们可以记录一下发起人的总数 也可以作为发起人的id
    uint neederId;
    // 另外我们还需要将id与发起人做一个映射，方便管理
    mapping(uint => needer) needMap;

    // 发起众筹 谁要发起众筹，需要众筹多少马尼呢？
    function newNeeder(address payable _neederAddress, uint _goal) public {
        // 发起人我们需要存储在区块链上以方便与后续查看 所以不能在内存中构造
        // needer memory newNeeder = needer(_neederAddress,_goal,0,0);

        // 不同的发起人
        // neederId++;
        // 将发起人与我们的计数做一个绑定
        // needMap[neederId] = needer(_neederAddress, _goal, 0, 0);
        needer storage n = needMap[neederId++];
        n.neederAddress = _neederAddress;
        n.goal = _goal;
        n.amount = 0;
        n.funderAmount = 0;
    }

    // 捐赠（看他们那么可怜，我拉上朋友一起给他们捐赠吧）
    // 那么到底是谁捐赠的？那我要捐赠给谁？
    function contribute(
        address _funderAddress,
        uint _neederAmount
    ) public payable {
        // 根据id确定我要捐给谁
        needer storage _needer = needMap[_neederAmount];
        // 我要把捐500块钱，直接打给我想要捐的那个人的账户余额里
        // 通过msg.value全局变量确认我要捐多少钱
        _needer.amount += msg.value;
        // 有人给我捐款+1 （此处直接 个数等同于捐赠人id）
        _needer.funderAmount++;
        // 构造捐赠人(是谁 给我捐赠的，捐了多少马尼)，最终要捐赠给谁
        _needer.map[_needer.funderAmount] = funder(_funderAddress, msg.value);
    }

    // 请求捐赠不同于乞讨，我们获取到了我们需要的马尼之后，就该结束了。
    // 而乞讨确实可以作为终身职业。emm 此处应该有一个五味杂陈的表情
    // 接收捐赠是否结束？（我发起众筹已经有一些时日了 灾情也结束了 我该看看是不是可以结束筹集马尼了）
    function isComplete(uint _neederId) public {
        // 根据发起人id获取发起人的筹mn信息
        needer storage _needer = needMap[_neederId];
        // 如果筹集的马尼已经大于我设定的目标筹款马尼时，那我就提现重新开始好好生活了~
        if (_needer.amount > _needer.goal) {
            // 提现
            _needer.neederAddress.transfer(_needer.amount);
        }
    }
}
