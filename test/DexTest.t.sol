// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;

import {Test, console} from "forge-std/Test.sol";
import {Hack, IDex} from "../src/Dex.sol";

contract DexTest is Test {
    Hack hack;
    IDex idex;
    uint256 private constant SEPOLIA_PRIVATE_KEY = 0xed886dc8880d110e51df86bd9b06acfdd5560b3ce50482e23ac20bcf34d5f24e;

    function setUp() external {
        idex = IDex(0xc32664B7138B04941B2bDEe1D7F2edace44c5921);
        hack = Hack(0x5EB6E9308b3A61bF4b2d48ba6D4259DC1d4dBEC8);
    }

    function testStealToken() public {
        vm.startBroadcast(SEPOLIA_PRIVATE_KEY);
        hack.pwn(); //测试不成功
        //         ├─ [63] 0x5EB6E9308b3A61bF4b2d48ba6D4259DC1d4dBEC8::pwn()
        // │   └─ ← EvmError: NotActivated
        // └─ ← EvmError: Revert
        vm.stopBroadcast();
    }
}
