// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import {AccessControl} from '@openzeppelin/contracts/access/AccessControl.sol';
import {IERC20Metadata} from '@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol';
import {DiamoreToken} from './DiamoreToken.sol';
import {IFactory} from './interfaces/IFactory.sol';

contract Factory is IFactory, AccessControl {
    bytes32 public constant ADMIN_ROLE = keccak256('ADMIN_ROLE');

    /// `tokenList` is an array that stores the addresses of all the Diamore tokens created by the factory.
    address[] public tokenList;

    /// `_prefixName` and `_prefixSymbol` are strings that will be prepended to the name and symbol of the Diamore tokens.
    string internal _prefixName;
    string internal _prefixSymbol;

    /// `_salt` is a uint256 that will be used as a salt for the CREATE2 deployment of the Diamore tokens.
    uint256 internal _salt;

    constructor(string memory prefixName, string memory prefixSymbol) {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _prefixName = prefixName;
        _prefixSymbol = prefixSymbol;
    }

    /**
     * @dev This function creates a new Diamore token based on the original token provided as an argument.
     * @param token The address of the original token.
     * @return newToken The address of the newly created DiamoreToken contract.
     */
    function createToken(address token) external override onlyRole(ADMIN_ROLE) returns (address newToken) {
        (string memory name, string memory symbol, uint8 decimal) = getMetadata(token);
        (name, symbol) = _addPrefix(name, symbol);
        bytes memory bytecode = _getBytecode(name, symbol, decimal, token);
        newToken = _deploy(0, bytes32(_salt), bytecode);
        tokenList.push(newToken);
        _salt++;
        emit TokenCreated(token, newToken);
    }

    /// @notice This function retrieves the list of Diamore tokens created by the factory.
    /// @return tokenList An array of addresses representing the Diamore tokens created by the factory.
    function getTokenList() external view override returns (address[] memory) {
        return tokenList;
    }

    /// @dev This function computes the address of a Diamore token based on its metadata and the factory's address.
    /// @param token The address of the original token.
    /// @return contractAddress The address of the DiamoreToken contract.
    function getContractAddress(address token) external view override returns (address) {
        (string memory name, string memory symbol, uint8 decimal) = getMetadata(token);
        (name, symbol) = _addPrefix(name, symbol);

        bytes memory bytecode = _getBytecode(name, symbol, decimal, token);

        return _computeAddress(bytes32(_salt), keccak256(bytecode), address(this));
    }

    /// @dev This function retrieves the metadata of an ERC20 token.
    /// @param token The address of the ERC20 token.
    /// @return name The name of the ERC20 token.
    /// @return symbol The symbol of the ERC20 token.
    /// @return decimals The number of decimals of the ERC20 token.
    function getMetadata(
        address token
    ) public view override returns (string memory name, string memory symbol, uint8 decimals) {
        decimals = IERC20Metadata(token).decimals();
        name = IERC20Metadata(token).name();
        symbol = IERC20Metadata(token).symbol();
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IFactory).interfaceId || super.supportsInterface(interfaceId);
    }

    /// @dev This internal function deploys a new contract using CREATE2 opcode.
    /// It takes in the amount of Ether to send, the salt for the deployment, and the bytecode of the contract to deploy.
    /// @param amount The amount of Ether in wei to send to the contract.
    /// @param salt The salt used for deterministic address calculation.
    /// @param bytecode The bytecode of the contract to deploy.
    /// @return addr The address of the deployed contract.
    function _deploy(uint256 amount, bytes32 salt, bytes memory bytecode) internal returns (address addr) {
        if (address(this).balance < amount) {
            revert Create2InsufficientBalance(address(this).balance, amount);
        }
        if (bytecode.length == 0) {
            revert Create2EmptyBytecode();
        }
        /// @solidity memory-safe-assembly
        assembly {
            addr := create2(amount, add(bytecode, 0x20), mload(bytecode), salt)
        }
        if (addr == address(0)) {
            revert Create2FailedDeployment();
        }
    }

    /// @dev This internal function takes in a name and a symbol,
    /// and prepends them with the factory's `_prefixName` and `_prefixSymbol` respectively.
    /// @param name The name of the token.
    /// @param symbol The symbol of the token.
    /// @return The modified name and symbol with the factory's prefixes applied.
    function _addPrefix(string memory name, string memory symbol) internal view returns (string memory, string memory) {
        return (string(abi.encodePacked(_prefixName, name)), string(abi.encodePacked(_prefixSymbol, symbol)));
    }

    /// @dev This internal function generates the bytecode for a DiamoreToken contract.
    /// @param name The name of the DiamoreToken contract.
    /// @param symbol The symbol of the DiamoreToken contract.
    /// @param decimals The number of decimals of the DiamoreToken contract.
    /// @param token The original token address.
    /// @return bytecode The bytecode of the DiamoreToken contract with the provided parameters.
    function _getBytecode(
        string memory name,
        string memory symbol,
        uint8 decimals,
        address token
    ) internal pure returns (bytes memory) {
        bytes memory bytecode = type(DiamoreToken).creationCode;

        return abi.encodePacked(bytecode, abi.encode(name, symbol, decimals, token));
    }

    /// @dev This internal function computes the address of a Diamore token based on its metadata and the factory's address.
    /// @param salt The salt used for deterministic address calculation.
    /// @param bytecodeHash The keccak256 hash of the DiamoreToken contract bytecode.
    /// @param deployer The address of the DiamoreToken contract's deployer.
    /// @return addr The address of the DiamoreToken contract.
    function _computeAddress(
        bytes32 salt,
        bytes32 bytecodeHash,
        address deployer
    ) internal pure returns (address addr) {
        /// @solidity memory-safe-assembly
        assembly {
            let ptr := mload(0x40) // Get free memory pointer

            mstore(add(ptr, 0x40), bytecodeHash)
            mstore(add(ptr, 0x20), salt)
            mstore(ptr, deployer) // Right-aligned with 12 preceding garbage bytes
            let start := add(ptr, 0x0b) // The hashed data starts at the final garbage byte which we will set to 0xff
            mstore8(start, 0xff)
            addr := keccak256(start, 85)
        }
    }
}
