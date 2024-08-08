# IDiamoreETHToken
[Git Source](https://github.com/DiamoreMarket/smart_contracts_sol/blob/1a7495662ef29cdbb3e771f245da1f2d67f4e41e/contracts/interfaces/IDiamoreETHToken.sol)


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

