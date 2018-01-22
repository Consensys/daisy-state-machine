# Sale

`Sale.sol` is an abstract sale contract from which child sales, such as Pryze, inherit. `Sale` inherits from `StateMachine` and `Ownable`.

The constructior recieves 4 parameters:
* `address _wallet`: the address of the multisig wallet where funds will be sent once the sale ends.
* `address _userRegistry`: the address of the UserRegistry contract.
* `uint256 _contributionCap`: max amount of ether to raise.
* `uint256 _minThreshold`: minimum amount of ether to raise.

## State Machine Stages

`SETUP`

Configuration stage. The start and end times for the sale need to be set in this stage in order to go to the next one. Also, time locked tokens need to be allocated in this stage by calling the `distributeTimelockedTokens` function.

Once the configuration is done, the owner needs to call the `setupDone` function, which makes the transition to the next stage after checking the configuration.

`SETUP_DONE`

This is just a freeze period in which no more configurations can be done.

`SALE_IN_PROGRESS`

This stage has both a start timestamp and an end timestamp. In this stage, whitelisted users (check out the docs for the UserRegistry) can contribute ether calling the `contribute` function.

The stage will transition to the next one if the end timestamp is reached or if the contribution cap is reached.

`SALE_ENDED`

If the sale was successful (minThreshold amount is reached), token allocations can begin. Anyone is able to call the `allocateTokens` function passing as a parameter the address of the contributor.
