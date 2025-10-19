// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {StakeContract} from "../src/StakeContract.sol";
import {MockERC20} from "./mocks/MockERC20.sol";
import {Cheats} from "./utils/Cheats.sol";

contract StakeContractTest is Test {
    Cheats internal constant CHEATS = Cheats(VM_ADDRESS);
    StakeContract public stakeContract;
    MockERC20 public mockERC20;
    function setUp() public {
        stakeContract = new StakeContract();
        mockERC20 = new MockERC20();
    }

    // 内置模糊器，循环遍历传入随机数
    function testExample(uint8 amount) public {
        mockERC20.approve(address(stakeContract),amount);
        // 作弊代码
        CHEATS.roll(55);
        bool stakePassed = stakeContract.stake(amount, address(mockERC20));
        assertTrue(stakePassed);
    }
}
