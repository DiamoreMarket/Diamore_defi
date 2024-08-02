# IDiamoreETHToken
[Git Source](https://github.com/DiamoreMarket/smart_contracts_sol/blob/edd6ba9db54e37902a75d85bd6f76310c4976943/contracts/interfaces/IDiamoreETHToken.sol)


## Functions
### exchange


```solidity
function exchange() external payable;
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

