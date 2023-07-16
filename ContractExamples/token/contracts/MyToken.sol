// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;
import "openzeppelin-solidity/contracts/utils/math/SafeMath.sol";

contract MyToken {
    // 扩展add和sub方法
    using SafeMath for uint256;
    // 自动生成get，set
    string public name = "MyToken";
    string public symbol = "MYT";
    uint256 public decimals = 18;
    uint256 public totalSupply;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    constructor() {
        totalSupply = 1000000 * (10 ** decimals);
        balanceOf[msg.sender] = totalSupply;
    }

    function transfer(
        address _to,
        uint256 _value
    ) public returns (bool success) {
        // 为真才向下执行
        require(_to != address(0));
        _transfer(msg.sender, _to, _from);
        return true;
    }

    function _transfer(address _from, address _to, uint256 _value) internal {
        require(balanceOf[_from] >= _value);
        balanceOf[_from] = balanceOf[_from].sub(_value);
        balanceOf[_to] = balanceOf[_to].add(_value);
        // 触发事件
        emit Transfer(_from, _to, _value);
    }

    event Transfer(address indexed _from, address indexed _to, uint256 _value);

    function approve(
        address _spender,
        uint256 _value
    ) public returns (bool success) {
        // msg.sender网页登录账号
        // _spender三方交易所地址
        // _value授权钱数
        require(_spender != address(0)); // 第二个参数是错误提示，错误会退回gas
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    // 被授权的交易所调用
    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) public returns (bool success) {
        // _from 放款账号
        // _to 收款账号
        // msg.sender 交易所账户地址
        require(balanceOf[_from] >= _value);
        require(allowance[_from][msg.sender] >= _value);
        allowance[_from][msg.sender] = allowance[_from][msg.sender].sub(_value);
        _transfer(_from, _to, _value);
        return true;
    }
}
