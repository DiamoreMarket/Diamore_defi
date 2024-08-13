# Factory
[Git Source](https://github.com/DiamoreMarket/smart_contracts_sol/blob/d9c233f3d22bc21895cd7ba877d73ff5b80f578a/contracts/Factory.sol)

**Inherits:**
[IFactory](/contracts/interfaces/IFactory.sol/interface.IFactory.md), AccessControl


## State Variables
### ADMIN_ROLE

```solidity
bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
```


### NATIVE

```solidity
address public constant NATIVE = 0x0000000000000000000000000000000000001010;
```


### tokenList
`tokenList` is an array that stores the addresses of all the Diamore tokens created by the factory.


```solidity
address[] public tokenList;
```


### _salt
`_salt` is a uint256 that will be used as a salt for the CREATE2 deployment of the Diamore tokens.


```solidity
uint256 internal _salt;
```


## Functions
### constructor


```solidity
constructor();
```

### createToken

*This function creates a new Diamore token based on the original token provided as an argument.*


```solidity
function createToken(address token, string memory name, string memory symbol)
    external
    override
    onlyRole(ADMIN_ROLE)
    returns (address newToken);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`token`|`address`|The address of the original token.|
|`name`|`string`||
|`symbol`|`string`||

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`newToken`|`address`|The address of the newly created DiamoreToken contract.|


### createNativeToken

*This function creates a new DiamoreETHToken contract.
The DiamoreETHToken is a specialized DiamoreToken that is backed by Ether (ETH).
Since ETH is a native asset on the Ethereum blockchain, the DiamoreETHToken is
created with a constant address (`NATIVE`) instead of an ERC20 token.*


```solidity
function createNativeToken(string memory name, string memory symbol)
    external
    override
    onlyRole(ADMIN_ROLE)
    returns (address newToken);
```

### getTokenList

This function retrieves the list of Diamore tokens created by the factory.


```solidity
function getTokenList() external view override returns (address[] memory);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`address[]`|tokenList An array of addresses representing the Diamore tokens created by the factory.|


### getContractAddress

*This function computes the address of a Diamore token based on its metadata and the factory's address.*


```solidity
function getContractAddress(address token, string memory name, string memory symbol)
    external
    view
    override
    returns (address);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`token`|`address`|The address of the original token.|
|`name`|`string`||
|`symbol`|`string`||

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`address`|contractAddress The address of the DiamoreToken contract.|


### getMetadata

*This function retrieves the metadata of an ERC20 token.*


```solidity
function getMetadata(address token)
    public
    view
    override
    returns (string memory name, string memory symbol, uint8 decimals);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`token`|`address`|The address of the ERC20 token.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`name`|`string`|The name of the ERC20 token.|
|`symbol`|`string`|The symbol of the ERC20 token.|
|`decimals`|`uint8`|The number of decimals of the ERC20 token.|


### supportsInterface

*See [IERC165-supportsInterface](/node_modules/@openzeppelin/contracts/governance/TimelockController.sol/contract.TimelockController.md#supportsinterface).*


```solidity
function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool);
```

### _deploy

*This internal function deploys a new contract using CREATE2 opcode.
It takes in the amount of Ether to send, the salt for the deployment, and the bytecode of the contract to deploy.*


```solidity
function _deploy(uint256 amount, bytes32 salt, bytes memory bytecode) internal returns (address addr);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`amount`|`uint256`|The amount of Ether in wei to send to the contract.|
|`salt`|`bytes32`|The salt used for deterministic address calculation.|
|`bytecode`|`bytes`|The bytecode of the contract to deploy.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`addr`|`address`|The address of the deployed contract.|


### _getBytecode

*This internal function generates the bytecode for a DiamoreToken contract.*


```solidity
function _getBytecode(string memory name, string memory symbol, uint8 decimals, address token)
    internal
    pure
    returns (bytes memory);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`name`|`string`|The name of the DiamoreToken contract.|
|`symbol`|`string`|The symbol of the DiamoreToken contract.|
|`decimals`|`uint8`|The number of decimals of the DiamoreToken contract.|
|`token`|`address`|The original token address.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bytes`|bytecode The bytecode of the DiamoreToken contract with the provided parameters.|


### _getBytecodeETH


```solidity
function _getBytecodeETH(string memory name, string memory symbol, uint8 decimals, address token)
    internal
    pure
    returns (bytes memory);
```

### _computeAddress

*This internal function computes the address of a Diamore token based on its metadata and the factory's address.*


```solidity
function _computeAddress(bytes32 salt, bytes32 bytecodeHash, address deployer) internal pure returns (address addr);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`salt`|`bytes32`|The salt used for deterministic address calculation.|
|`bytecodeHash`|`bytes32`|The keccak256 hash of the DiamoreToken contract bytecode.|
|`deployer`|`address`|The address of the DiamoreToken contract's deployer.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`addr`|`address`|The address of the DiamoreToken contract.|


