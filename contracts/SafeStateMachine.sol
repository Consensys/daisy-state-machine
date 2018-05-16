pragma solidity 0.4.23;

import "./StateMachine.sol";

contract SafeStateMachine is StateMachine {
    bytes32 public constant FALLBACK = keccak256("fallback");

    constructor() public {
        setFallbackState(FALLBACK);
        addCallback(FALLBACK, somethingWentWrong);
    }

    // The fallback should never be reached!
    function somethingWentWrong() internal {
        assert(true);
    }
}
