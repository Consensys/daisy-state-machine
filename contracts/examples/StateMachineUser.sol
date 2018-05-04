pragma solidity 0.4.23;

import "../TimedStateMachine.sol";


contract StateMachineUser is TimedStateMachine {

    bytes32 constant STATE1 = "state1";
    bytes32 constant STATE2 = "state2";
    bytes32 constant STATE3 = "state3";
    bytes32 constant STATE4 = "state4";
    bytes32[] states = [STATE1, STATE2, STATE3, STATE4];

    constructor() public {
        setupStates();
    }

    /* The 'checkAllowed' modifier will perform conditional transitions
    and check that the function is allowed at the current state */

    function() public checkAllowed {
        // Do something
    }
        
    function foo() public checkAllowed {
        // Do something
    }

    function bar() public checkAllowed {
        // Do something
    }

    function setupStates() internal {
        setStates(states);

        allowFunction(STATE1, this.foo.selector);
        allowFunction(STATE2, this.bar.selector);
        allowFunction(STATE3, 0); // Allow fallback function

        addCallback(STATE1, onState1);
        addCallback(STATE2, onState2);
        addCallback(STATE3, onState3);

        setStateStartTime(STATE2, now + 2 weeks);
        setStateStartTime(STATE3, now + 3 weeks);

        addStartCondition(STATE4, shouldState4Start);
    }

    // Callback when entering each state
    function onState1() internal { /* Do something */ }
    function onState2() internal { /* Do something */ }
    function onState3() internal { /* Do something */ }

    function shouldState4Start(bytes32) internal returns(bool) {
        return true;
    }

}
