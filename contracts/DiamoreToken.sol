// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import {IERC20, ERC20} from '@openzeppelin/contracts/token/ERC20/ERC20.sol';
import {SafeERC20} from '@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol';
import {IDiamoreToken} from 'contracts/interfaces/IDiamoreToken.sol';
import {IERC165} from '@openzeppelin/contracts/utils/introspection/IERC165.sol';
import {Test, console, Vm} from 'forge-std/src/Test.sol';

/// @title DiamoreToken
/// @author The Diamore Team
/// @notice Diamore tokens are ERC20 tokens that can be exchanged for a specified amount of the original tokens.
/// @dev Diamore tokens are created by the factory contract.
contract DiamoreToken is IERC165, IDiamoreToken, ERC20 {
    using SafeERC20 for IERC20;
    address public originalToken;
    uint8 internal _decimal;

    /// @dev Constructor for DiamoreToken.
    /// @param name The name of the token.
    /// @param symbol The symbol of the token.
    /// @param dec The decimal of the token.
    /// @param origToken The original token address.
    constructor(string memory name, string memory symbol, uint8 dec, address origToken) ERC20(name, symbol) {
        _decimal = dec;
        originalToken = origToken;
    }

    /// @notice This function allows users to exchange their tokens for diamore tokens.
    /// @dev This function transfers the specified amount of tokens from the caller's account to the DiamoreToken contract.
    /// If the specified amount is zero, the function will revert with the message 'Zero amount'.
    /// @param amount The amount of tokens to be exchanged.
    function exchange(uint256 amount) external override {
        if (amount == 0) revert('Zero amount');
        IERC20(originalToken).safeTransferFrom(msg.sender, address(this), amount);
        _mint(msg.sender, amount);

        emit Exchange({tokenFrom: originalToken, tokenTo: address(this), sender: msg.sender, amount: amount});
    }

    /// @notice This function allows users to reverse exchange their diamore tokens for their original tokens.
    /// @dev This function burns the specified amount of diamore tokens from the caller's account
    /// and transfers the specified amount of original tokens to the caller's account.
    /// If the specified amount is zero, the function will revert with the message 'Zero amount'.
    /// @param amount The amount of diamore tokens to be reversed.
    function reverseExchange(uint256 amount) external override {
        _burn(msg.sender, amount);

        IERC20(originalToken).safeTransfer(msg.sender, amount);

        emit Exchange({tokenFrom: address(this), tokenTo: originalToken, sender: msg.sender, amount: amount});
    }

    function decimals() public view override returns (uint8) {
        return _decimal;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC20).interfaceId || interfaceId == type(IDiamoreToken).interfaceId;
    }
}
