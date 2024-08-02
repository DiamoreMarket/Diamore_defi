// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IDiamoreETHToken {
    event Exchange(address tokenFrom, address tokenTo, address sender, uint256 amount);

    function exchange() external payable;

    function reverseExchange(uint256 amount) external;
}