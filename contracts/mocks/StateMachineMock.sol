pragma solidity 0.4.19;

import "../../contracts/StateMachine.sol";


contract StateMachineMock is StateMachine {
    bytes4 public dummyFunctionSelector = this.dummyFunction.selector;

    bool public condition = false;
    bool public callbackCalled = false;

    function StateMachineMock() public { 
    }

    function setStatesHelper(bytes32[] _states) public {
        stateMachine.setStates(_states);
    }

    function dummyFunction() public checkAllowed {
    }

    function dummyCondition(bytes32) internal returns(bool) {
        return true;
    }

    function dummyVariableCondition(bytes32) internal returns(bool) {
        return condition;
    }

    function dummyCallback() internal {
        callbackCalled = true;
    }

    // Helper to test creating transitions
    function createTransition(bytes32 fromId, bytes32 toId) public {
        stateMachine.createTransition(fromId, toId);
    }

    // Helper to test going to next state
    function goToNextStateHelper() public {
        stateMachine.goToNextState();
    }

    // Sets the dummy condition for a state
    function setDummyCondition(bytes32 stateId) public {
        stateMachine.addStartCondition(stateId, dummyCondition);
    }

    function setCondition(bool _condition) public {
        condition = _condition;
    }

    // Sets the dummy callback condition for a state
    function setDummyVariableCondition(bytes32 stateId) public {
        stateMachine.addStartCondition(stateId, dummyVariableCondition);
    }

    // Sets the dummy callback for a state
    function setDummyCallback(bytes32 stateId) public {
        stateMachine.addCallback(stateId, dummyCallback);
    }

    // Helper to test allowing a function
    function allowFunction(bytes32 stateId, bytes4 selector) public {
        stateMachine.allowFunction(stateId, selector);
    }

}
