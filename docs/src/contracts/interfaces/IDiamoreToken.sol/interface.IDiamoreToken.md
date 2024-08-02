# IDiamoreToken
[Git Source](https://github.com/DiamoreMarket/smart_contracts_sol/blob/master/contracts/interfaces/IDiamoreToken.sol)


## Functions
### exchange


```solidity
function exchange(uint256 amount) external;
```

### reverseExchange


```solidity
function reverseExchange(uint256 amount) external;
```

## Events
### Exchange

```solidity
event Exchange(address tokenFrom, address tokenTo, address sender, uint256 amount);
```

