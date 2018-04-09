# State Machine
[![npm version](https://badge.fury.io/js/%40tokenfoundry%2Fstate-machine.svg)](https://badge.fury.io/js/%40tokenfoundry%2Fstate-machine)
[![CircleCI](https://circleci.com/gh/tokenfoundry/state-machine.svg?style=shield)](https://circleci.com/gh/tokenfoundry/state-machine)
[![Coverage Status](https://coveralls.io/repos/github/tokenfoundry/state-machine/badge.svg?branch=master)](https://coveralls.io/github/tokenfoundry/state-machine?branch=master)

In order to use, build and test the contracts found in this repo, [Truffle](truffleframework.com) version > 4 is needed.

These contracts have **not** been audited, use them with caution.

## Usage

First install as a npm package in your truffle project directory:
```
yarn add -E @tokenfoundry/state-machine
```

Import in your contracts:
```
import "@tokenfoundry/state-machine/contracts/StateMachine.sol";

contract MyContract is StateMachine {
  ...
}
```

Please read the [docs](./docs/StateMachine.md) and the [examples](./contracts/examples/) for more information about how to use this.


## Testing

To run the tests, clone this repo and run `yarn install` to install dependencies.

Run `yarn test` to run all the tests.

Run `yarn coverage` to run tests and get code coverage.

## License

MIT
