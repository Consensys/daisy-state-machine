pragma solidity 0.4.23;

import "./StateMachine.sol";

contract SafeStateMachine is StateMachine {
    constructor() public {
        addCallback(FALLBACK, somethingWentWrong);
    }

    // The fallback should never be reached!
    function somethingWentWrong() internal {
        assert(true);
    }
}
