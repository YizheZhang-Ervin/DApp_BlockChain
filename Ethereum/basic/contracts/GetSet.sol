// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

contract GetSet {
    // 可设置可公开访问，取值自动有get方法：obj.age()
    uint public age;
    string name;

    // struct，动态数组，映射，string会要求设置memory/calldata/storage
    // 访问级别public,external,initernal,private
    // 变量作用域：状态变量/局部变量/全局变量(msg.sender/block.number)
    function setData(string memory _name, uint _age) public {
        name = _name;
        age = _age;
    }

    // 函数类型：view（只访问不修改，不花钱），pure（不访问不修改，不涉及外部变量）
    function getData() public view returns (string memory, uint) {
        return (name, age);
    }
}
