// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

contract CrowdFunding {
    //赞助人
    struct funder {
        address funderAddr;
        uint money; //捐赠的数额
    }
    //被赞助人
    struct needer {
        address neederAddr;
        uint goal; //众筹的目标资金
        uint current; //目前筹集到的资金
        uint funderAmount;
        mapping(uint => funder) funderMap;
    }

    //合约属性
    uint neederAmount;
    mapping(uint => needer) neederMap;

    //被赞助人构造
    function newNeeder(address _neederAddr, uint _goal) public {
        // neederAmount++;
        // neederMap[neederAmount] = needer(_neederAddr, _goal, 0, 0); //type mapping can be ignore in constructor

        needer storage n = neederMap[neederAmount++];
        n.neederAddr = _neederAddr;
        n.goal = _goal;
        n.current = 0;
        n.funderAmount = 0;
    }

    //赞助
    function contribute(address _funderAddr, uint _neederId) public payable {
        needer storage _needer = neederMap[_neederId];
        _needer.current += msg.value; //msg is a global variaty
        _needer.funderAmount++;
        _needer.funderMap[_needer.funderAmount] = funder(
            _funderAddr,
            msg.value
        );
    }

    //judge if the crowdfunding have completed
    function judgeCompleted(uint _neederId) public {
        needer storage _needer = neederMap[_neederId];
        if (_needer.current >= _needer.goal)
            payable(_needer.neederAddr).transfer(_needer.current);
    }

    //show the status of a needer
    function showNeeder(uint _neederId) public view returns (uint, uint, uint) {
        needer storage _needer = neederMap[_neederId];
        return (_needer.goal, _needer.current, _needer.funderAmount);
    }
}
