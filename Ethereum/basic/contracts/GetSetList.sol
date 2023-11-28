// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

contract GetSetList {
    struct A {
        uint id;
        string name;
        uint age;
        address account;
    }
    // 动态数组
    A[] public aLis;

    function addList(string memory _name, uint _age) public returns (uint) {
        uint count = aLis.length;
        uint index = count + 1;
        // sender发起交易的人
        aLis.push(A(index, _name, _age, msg.sender));
        return aLis.length;
    }

    function getList() public view returns (A[] memory) {
        A[] memory list = aLis;
        return list;
    }
}
