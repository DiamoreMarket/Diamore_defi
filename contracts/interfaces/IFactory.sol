// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IFactory {
    event TokenCreated(address token, address newToken);

    /**
     * @dev Not enough balance for performing a CREATE2 deploy.
     */
    error Create2InsufficientBalance(uint256 balance, uint256 needed);

    /**
     * @dev There's no code to deploy.
     */
    error Create2EmptyBytecode();

    /**
     * @dev The deployment failed.
     */
    error Create2FailedDeployment();

    function createToken(address token) external returns (address newToken);

    function createNativeToken() external returns (address newToken);

    function getTokenList() external view returns (address[] memory);

    function getContractAddress(address token) external view returns (address);

    function getMetadata(
        address token
    ) external view returns (string memory name, string memory symbol, uint8 decimals);
}
