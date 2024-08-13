// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IDiamoreToken {
    event Exchange(address tokenFrom, address tokenTo, address sender, uint256 amount);

    function deposit(uint256 amount) external;

    function withdraw(uint256 amount) external;
}
