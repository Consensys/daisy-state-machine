pragma solidity 0.4.19;

import "../../contracts/StateMachine.sol";


contract StateMachineMock is StateMachine {
    bytes4 public dummyFunctionSelector = this.dummyFunction.selector;

    bool public condition = false;
    bool public callbackCalled = false;

    function StateMachineMock() public { 
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

    // Helper to set the initial state
    function setInitialStateHelper(bytes32 _stateId) public {
        stateMachine.setInitialState(_stateId);
    }

    // Helper to test creating transitions
    function createTransitionHelper(bytes32 _fromId, bytes32 _toId) public {
        stateMachine.createTransition(_fromId, _toId);
    }

    // Helper to test creating transitions
    function createTransitionArrayHelper(bytes32 _fromId, bytes32[] _toIds) public {
        stateMachine.createTransition(_fromId, _toIds);
    }

    // Helper to test going to next state
    function goToNextStateHelper(bytes32 _nextStateId) public {
        stateMachine.goToNextState(_nextStateId);
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
