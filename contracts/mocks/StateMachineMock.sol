pragma solidity 0.4.23;

import "../../contracts/StateMachine.sol";


contract StateMachineMock is StateMachine {
    bytes4 public dummyFunctionSelector = this.dummyFunction.selector;

    bool public condition = false;
    bool public callbackCalled = false;

    function dummyFunction() public checkAllowed {
    }

    function dummyCondition(bytes32, bytes32) internal returns(bool) {
        return true;
    }

    function dummyVariableCondition(bytes32, bytes32) internal returns(bool) {
        return condition;
    }

    function dummyCallback() internal {
        callbackCalled = true;
    }

    function setInitialStateHelper(bytes32 _stateId) public {
        setInitialState(_stateId);
    }

    // Helper to test going to next state
    function goToStateHelper(bytes32 _stateId) public {
        goToState(_stateId);
    }

    // Sets the dummy condition for a state
    function setDummyCondition(bytes32 _fromId, bytes32 _toId) public {
        addStartCondition(_fromId, _toId, dummyCondition);
    }

    function setCondition(bool _condition) public {
        condition = _condition;
    }

    // Sets the dummy callback condition for a state
    function setDummyVariableCondition(bytes32 _fromId, bytes32 _toId) public {
        addStartCondition(_fromId, _toId, dummyVariableCondition);
    }

    // Sets the dummy callback for a state
    function setDummyTransitionCallback(bytes32 _fromId, bytes32 _toId) public {
        addCallback(_fromId, _toId, dummyCallback);
    }
    
    function setDummyStateCallback(bytes32 _stateId) public {
        addCallback(_stateId, dummyCallback);
    }

    // Helper to test allowing a function
    function allowFunctionHelper(bytes32 stateId, bytes4 selector) public {
        allowFunction(stateId, selector);
    }

}
