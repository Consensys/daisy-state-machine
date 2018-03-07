# State Machine

[![Coverage Status](https://coveralls.io/repos/github/tokenfoundry/state-machine/badge.svg?branch=master)](https://coveralls.io/github/tokenfoundry/state-machine?branch=master)
[![CircleCI](https://circleci.com/gh/tokenfoundry/state-machine.svg?style=shield)](https://circleci.com/gh/tokenfoundry/state-machine)

In order to use, build and test the contracts found in this repo, [Truffle](truffleframework.com) version > 4 is needed.

## Usage

First install as a npm package in your truffle project directory:
```
npm install -E @tokenfoundry/state-machine
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

To run the tests, clone this repo and run `npm install` to install dependencies.

Run `truffle test` to run all the tests.

Run `npm run coverage` to run tests and get code coverage.

## License

MIT
