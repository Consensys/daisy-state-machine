pragma solidity 0.4.19;

import "../TimedStateMachine.sol";


contract StateMachineUser is TimedStateMachine {

    bytes32 constant STATE0 = "STATE0";
    bytes32 constant STATE1A = "STATE1A";
    bytes32 constant STATE1B = "STATE1B";
    bytes32 constant STATE2 = "STATE2";
    bytes32 constant STATE3 = "STATE3";
    bytes32 constant STATE4 = "STATE4";

    function StateMachineUser() public {
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
        stateMachine.setInitialState(STATE0);
        stateMachine.createTransition(STATE0, STATE1A);
        stateMachine.createTransition(STATE0, STATE1B);
        stateMachine.createTransition(STATE1A, STATE2);
        stateMachine.createTransition(STATE1B, STATE2);
        stateMachine.createTransition(STATE2, STATE3);

        stateMachine.allowFunction(STATE1A, this.foo.selector);
        stateMachine.allowFunction(STATE2, this.bar.selector);
        stateMachine.allowFunction(STATE3, 0); // Allow fallback function

        stateMachine.addCallback(STATE1A, onState1A);
        stateMachine.addCallback(STATE2, onState2);
        stateMachine.addCallback(STATE3, onState3);

        setStateStartTime(STATE2, now + 2 weeks);
        setStateStartTime(STATE3, now + 3 weeks);

        stateMachine.addStartCondition(STATE4, shouldState4Start);
    }

    // Callback when entering each state
    function onState1A() internal { /* Do something */ }
    function onState2() internal { /* Do something */ }
    function onState3() internal { /* Do something */ }

    function shouldState4Start(bytes32) internal returns(bool) {
        return true;
    }

}