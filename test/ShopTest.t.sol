// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;

import {Test, console} from "forge-std/Test.sol";
import {Shop, Buyer} from "../src/Shop.sol";

contract ShopTest is Test {
    Shop shop;
    Buyer buyer;

    function setUp() external {
        vm.startBroadcast();
        shop = new Shop();
        buyer = new Buyer(address(shop));
        vm.stopBroadcast();
    }

    function testShop() public {
        buyer.pwn();
        assert(shop.isSold() == true);
        assert(shop.price() == 99);
    }
}
