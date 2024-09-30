// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface ITreasure {
    event ApproveCollection(address user, address collection, address operator, bool status);
    event Withdraw(address user, uint256 amount, address token, address to);
    event Approve(address user, uint256 amount, address token, address to);
    event Deposit(address user, uint256 amount, address token);
    event WithdrawNft(address sender, address owner, uint256 tokenId);
    event Refund(address owner, uint256 tokenId);

    function depositErc20(uint256 amount, address token) external;

    function withdrawErc20(uint256 amount, address token, address to) external;

    function approveErc20(uint256 amount, address to, address token) external;

    function approveCollection(address operator, bool status) external;

    function refundNft(uint256 tokenId) external;

    function withdrawNft(uint256 tokenId, address to) external;

    function balanceOf(address token) external view returns (uint256);
}
