// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;

import {Test, console} from "forge-std/Test.sol";
import {GatekeeperOne, Hack} from "../src/GatekeeperOne.sol";

contract HackTest {
    GatekeeperOne private gatekeeperOne;
    Hack private hack;

    function setUp() external {
        gatekeeperOne = GatekeeperOne(
            0xD10E12ADD46Ab3F374c06e006Cf7A68C01687432
        );
        hack = new Hack();
    }

    function testGas() public {
        for (uint256 i = 0; i < 8191; i++) {
            try hack.attack(address(gatekeeperOne), i) {
                console.log("gas: ", i);
                return;
            } catch {}
        }
        revert("all failed");
    }
}
