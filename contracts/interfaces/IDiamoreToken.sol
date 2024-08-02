// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IDiamoreToken {
    event Exchange(address tokenFrom, address tokenTo, address sender, uint256 amount);

    function exchange(uint256 amount) external;

    function reverseExchange(uint256 amount) external;
}
