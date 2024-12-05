// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IERC20, SafeERC20} from '@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol';
import {AccessControl} from '@openzeppelin/contracts/access/AccessControl.sol';
import {IERC721} from '@openzeppelin/contracts/token/ERC721/IERC721.sol';
import {ITreasure} from './ITreasure.sol';
import {ERC721Holder} from '@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol';

contract Treasure is AccessControl, ERC721Holder, ITreasure {
    using SafeERC20 for IERC20;

    bytes32 public constant ADMIN_ROLE = keccak256('ADMIN_ROLE');
    address public collection;

    constructor(address admin, address collectionNFT, address stakingAddress, address token) {
        collection = collectionNFT;
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(ADMIN_ROLE, admin);
        _approveCollection(stakingAddress, true);
        _approveErc20(type(uint256).max, stakingAddress, token);
    }

    function approveErc20(uint256 amount, address to, address token) external override onlyRole(ADMIN_ROLE) {
        _approveErc20(amount, to, token);
    }

    function depositErc20(uint256 amount, address token) external override onlyRole(ADMIN_ROLE) {
        IERC20(token).safeTransferFrom(msg.sender, address(this), amount);
        emit Deposit(msg.sender, amount, token);
    }

    function withdrawErc20(uint256 amount, address token, address to) external override onlyRole(ADMIN_ROLE) {
        IERC20(token).safeTransfer(to, amount);
        emit Withdraw(msg.sender, amount, token, to);
    }

    function approveCollection(address operator, bool status) external override onlyRole(ADMIN_ROLE) {
        _approveCollection(operator, status);
    }

    function refundNft(uint256 tokenId) external override onlyRole(ADMIN_ROLE) {
        IERC721(collection).safeTransferFrom(msg.sender, address(this), tokenId);

        emit Refund(msg.sender, tokenId);
    }

    function withdrawNft(uint256 tokenId, address to) external override onlyRole(ADMIN_ROLE) {
        IERC721(collection).safeTransferFrom(address(this), to, tokenId);

        emit WithdrawNft(msg.sender, to, tokenId);
    }

    function balanceOf(address token) external view override returns (uint256) {
        return IERC20(token).balanceOf(address(this));
    }

    function _approveCollection(address operator, bool status) internal {
        IERC721(collection).setApprovalForAll(operator, status);
        emit ApproveCollection(msg.sender, collection, operator, status);
    }

    function _approveErc20(uint256 amount, address to, address token) internal {
        IERC20(token).forceApprove(to, amount);
        emit Approve(msg.sender, amount, token, to);
    }
}
