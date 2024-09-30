// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "contracts/nft/lib/@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "contracts/nft/lib/@openzeppelin/contracts/utils/cryptography/SignatureChecker.sol";
import "contracts/nft/lib/@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

interface IERC721Permit {
    function DOMAIN_SEPARATOR() external view returns (bytes32);

    /**
     * @notice Allows to retrieve current nonce for token
     * @param account user address
     * @return current token nonce
     */
    function nonces(address account) external view returns (uint256);

    /**
     * @notice function to be called by anyone to approve `spender` using a Permit signature
     * @dev Anyone can call this to approve `spender`, event a third-party
     * @param owner the owner who approve
     * @param spender the actor to approve
     * @param deadline the deadline for the permit to be used
     * @param v V component
     * @param r R component
     * @param s S component
     */
    function permit(
        address owner,
        address spender,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;
}
