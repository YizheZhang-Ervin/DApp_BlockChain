// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.13;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
contract MockERC20 is ERC20 {
    constructor() ERC20 ("MOCk ERC20", "MERC"){
        _mint(msg.sender,1000000e18);
    }
}