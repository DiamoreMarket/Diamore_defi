# IFactory
[Git Source](https://github.com/DiamoreMarket/smart_contracts_sol/blob/master/contracts/interfaces/IFactory.sol)


## Functions
### createToken


```solidity
function createToken(address token) external returns (address newToken);
```

### getTokenList


```solidity
function getTokenList() external view returns (address[] memory);
```

### getContractAddress


```solidity
function getContractAddress(address token) external view returns (address);
```

### getMetadata


```solidity
function getMetadata(address token) external view returns (string memory name, string memory symbol, uint8 decimals);
```

## Events
### TokenCreated

```solidity
event TokenCreated(address token, address newToken);
```

## Errors
### Create2InsufficientBalance
*Not enough balance for performing a CREATE2 deploy.*


```solidity
error Create2InsufficientBalance(uint256 balance, uint256 needed);
```

### Create2EmptyBytecode
*There's no code to deploy.*


```solidity
error Create2EmptyBytecode();
```

### Create2FailedDeployment
*The deployment failed.*


```solidity
error Create2FailedDeployment();
```
