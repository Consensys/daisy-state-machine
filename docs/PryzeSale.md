# Pryze

`PryzeSale` inherits from `Sale` and `Whitelistable`.

In this sale, tokens are allocated at the end because the amount of tokens to allocate to each user will depend on the total amount of wei raised. Pryze has already raised funds in a presale, so users that contributed in the presale need to be registered in the contract, in order to allocate tokens to them.

## Sale Parameters

Constants:
* `uint256 public constant PRESALE_WEI`: Amount raised in the presale
* `uint256 public constant PRESALE_WEI_WITH_BONUS`: Amount raised in the presale including the bonus (`PRESALE_WEI` * 1.5)
* `uint256 public constant MAX_WEI`: Max wei to raise, including `PRESALE_WEI`
* `uint256 public constant WEI_CAP`: Max wei to raise in the public sale (`MAX_WEI - PRESALE_WEI`)
* `uint256 public constant MAX_TOKENS`: Total amount of tokens to allocate, considering decimals

Variables:
* `uint256 public presaleWeiContributed`: Stores the current amount of presale contributions set with the `presaleContribute` function.
* `uint256 private weiAllocated`: Stores the amount of wei that has been already "converted" to tokens with the `allocateTokens` function.

Constructor arguments:
* `address _wallet`: The address of the multisig where contributions will be sent.

## Presale

In order to allocate the tokens for presale contributors, we use the `presaleContribute` function to manually set their contributions. If the `presaleContribute` function is called for the same address more than one time, the old presale contribution will be **replaced**.

## Contribution limit

There is no contribution limit for *whitelisted* addresses, and a contribution limit of 0 (not allowed to contribute) for non whitelisted ones.

## Token allocations

The `allocateTokens` function can be called at the end of the sale only (`SALE_ENDED` stage). It uses the presale and public sale contributions made by the specified user to compute the amount of tokens to allocate. It also sets the contributions to 0 and increments the `weiAllocated` function. Finally, it mints the tokens to the contributor and if every wei was allocated, it disables the token's minting functionality permanently.

The tokens allocated to a *contributor* at the end of the sale are equal to `(presale * 1.5 + pubsale) * MAX_TOKENS / (total contributions)`, where `presale` is the amount he contributed in the presale, `pubsale` is the amount he contributed in the public sale, `MAX_TOKENS` is the total amount of tokens to allocate and `total contributions` is the total amount raised in the presale **with the bonus** plus the total amount raised in the public sale. This is implemented in the `calculateAllocation` function.
