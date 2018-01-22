# sale-contracts

Code for the new token foundry token and sale base contracts.

## Contracts

State Machine pattern:

- [StateMachineLib.sol](/contracts/StateMachineLib.sol): Library that contains structs and functions that handle state machine logic.
- [StateMachine.sol](/contracts/StateMachine): Base contract that makes use of StateMachineLib to implement basic state machine functionality.
- [TimedStateMachine.sol](/contracts/TimedStateMachine.sol): Base contract that inherits from StateMachine and adds time based transitions for the stages.

Sale:

- [Sale.sol](/contracts/Sale.sol): Abstract base contract from which all sales inherit. It implements a basic sale structure and common functions.
- [DisbursementHandler.sol](/contracts/DisbursementHandler.sol): Contract that is used by the sale in order to lock tokens until a timestamp.

## Instructions

In order to build and test the contracts found in this repo, [Truffle](truffleframework.com) version > 4 is needed.

### Building

Once the repo is cloned, run `npm install` to install all the dependencies.

Running `truffle compile` will compile the contract code and place the output in the `build/contracts` directory.

### Testing

`truffle test` to run all the tests.

`npm run coverage` to run tests and get code coverage.

To perform test on a local Geth node, `cd` into the project directory and do the following:

If you don't have existing accounts or chaindata, enter `.geth/reinit-geth`

Enter `.geth/start-geth` to start the local node. You can see the output by entering `tail -f ~/.ethereum.log`.

When running Truffle tests, add `--network localGethNode` to utilize the local Geth node.

## License

MIT
