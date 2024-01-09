// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;

import {Test, console} from "forge-std/Test.sol";
import {GatekeeperTwo, Hack} from "../src/GatekeeperTwo.sol";

contract gateTest {
    address target = 0xf3FF47b3BF172027ebb544D3e9eac7EBbcF257b3;
    Hack private hack;

    function setUp() external {}

    function testGate() public {
        hack = new Hack(target);
    }
}
