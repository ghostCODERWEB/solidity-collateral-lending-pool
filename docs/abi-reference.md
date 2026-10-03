# ABI reference

Generated from the successfully compiled primary contract. Includes inherited methods. Authorization and economic semantics are documented in the source.

| Signature | Type | Mutability | Returns |
|---|---|---|---|
| `constructor(address asset,uint256 initialPrice,uint256 oracleAge,address admin)` | constructor | nonpayable |  |
| `ERC20InsufficientAllowance(address spender,uint256 allowance,uint256 needed)` | error |  |  |
| `ERC20InsufficientBalance(address sender,uint256 balance,uint256 needed)` | error |  |  |
| `ERC20InvalidApprover(address approver)` | error |  |  |
| `ERC20InvalidReceiver(address receiver)` | error |  |  |
| `ERC20InvalidSender(address sender)` | error |  |  |
| `ERC20InvalidSpender(address spender)` | error |  |  |
| `EnforcedPause()` | error |  |  |
| `ExpectedPause()` | error |  |  |
| `OwnableInvalidOwner(address owner)` | error |  |  |
| `OwnableUnauthorizedAccount(address account)` | error |  |  |
| `ReentrancyGuardReentrantCall()` | error |  |  |
| `SafeERC20FailedOperation(address token)` | error |  |  |
| `Approval(address owner,address spender,uint256 value)` | event |  |  |
| `Borrowed(address borrower,uint256 amount)` | event |  |  |
| `Liquidated(address borrower,uint256 repaid,uint256 collateralSeized,uint256 writtenOff)` | event |  |  |
| `OracleUpdated(uint256 price)` | event |  |  |
| `OwnershipTransferStarted(address previousOwner,address newOwner)` | event |  |  |
| `OwnershipTransferred(address previousOwner,address newOwner)` | event |  |  |
| `Paused(address account)` | event |  |  |
| `Repaid(address borrower,uint256 amount)` | event |  |  |
| `Transfer(address from,address to,uint256 value)` | event |  |  |
| `Unpaused(address account)` | event |  |  |
| `BONUS()` | function | view | uint16  |
| `LIQUIDATION()` | function | view | uint16  |
| `LTV()` | function | view | uint16  |
| `acceptOwnership()` | function | nonpayable |  |
| `addCollateral()` | function | payable |  |
| `allowance(address owner,address spender)` | function | view | uint256  |
| `approve(address spender,uint256 value)` | function | nonpayable | bool  |
| `badDebt()` | function | view | uint256  |
| `balanceOf(address account)` | function | view | uint256  |
| `borrow(uint256 amount)` | function | nonpayable |  |
| `collateral(address )` | function | view | uint256  |
| `collateralValue(address account)` | function | view | uint256  |
| `debt(address )` | function | view | uint256  |
| `decimals()` | function | view | uint8  |
| `deposit(uint256 assets)` | function | nonpayable | uint256 shares |
| `liquidate(address account,uint256 maxRepay)` | function | nonpayable |  |
| `loanToken()` | function | view | address  |
| `maxOracleAge()` | function | view | uint256  |
| `name()` | function | view | string  |
| `owner()` | function | view | address  |
| `paused()` | function | view | bool  |
| `pendingOwner()` | function | view | address  |
| `price()` | function | view | uint256  |
| `priceUpdated()` | function | view | uint256  |
| `redeem(uint256 shares)` | function | nonpayable | uint256 assets |
| `removeCollateral(uint256 amount)` | function | nonpayable |  |
| `renounceOwnership()` | function | nonpayable |  |
| `repay(address account,uint256 amount)` | function | nonpayable |  |
| `setPaused(bool value)` | function | nonpayable |  |
| `setPrice(uint256 value)` | function | nonpayable |  |
| `symbol()` | function | view | string  |
| `totalAssets()` | function | view | uint256  |
| `totalDebt()` | function | view | uint256  |
| `totalSupply()` | function | view | uint256  |
| `transfer(address to,uint256 value)` | function | nonpayable | bool  |
| `transferFrom(address from,address to,uint256 value)` | function | nonpayable | bool  |
| `transferOwnership(address newOwner)` | function | nonpayable |  |
