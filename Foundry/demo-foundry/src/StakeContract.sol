//SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

error TransferFailed();

contract StakeContract {
    mapping(address => mapping(address => uint256)) public sBalances;

    function stake(uint256 amount, address token) external returns(bool) {
        sBalances[msg.sender][token]+= amount;
        bool success = IERC20(token).transferFrom(msg.sender,address(this),amount);
        if(!success) revert TransferFailed();
        return success;
    }
}