pragma solidity 0.4.23;

import "../../contracts/StateMachine.sol";


contract StateMachineMock is StateMachine {
    bytes4 public dummyFunctionSelector = this.dummyFunction.selector;

    bool public condition = false;
    bool public callbackCalled = false;

    function dummyFunction() external checkAllowed {
    }

    function setInitialStateHelper(bytes32 _stateId) external {
        setInitialState(_stateId);
    }

    function setFallbackStateHelper(bytes32 _stateId) external {
        setFallbackState(_stateId);
    }

    // Helper to test going to next state
    function goToStateHelper(bytes32 _stateId) external {
        goToState(_stateId);
    }

    // Sets the dummy condition for a state
    function setDummyCondition(bytes32 _fromId, bytes32 _toId) external {
        addStartCondition(_fromId, _toId, dummyCondition);
    }

    function setCondition(bool _condition) external {
        condition = _condition;
    }

    // Sets the dummy callback condition for a state
    function setDummyVariableCondition(bytes32 _fromId, bytes32 _toId) external {
        addStartCondition(_fromId, _toId, dummyVariableCondition);
    }

    // Sets the dummy callback for a state
    function setDummyTransitionCallback(bytes32 _fromId, bytes32 _toId) external {
        addCallback(_fromId, _toId, dummyCallback);
    }
    
    function setDummyStateCallback(bytes32 _stateId) external {
        addCallback(_stateId, dummyCallback);
    }

    // Helper to test allowing a function
    function allowFunctionHelper(bytes32 stateId, bytes4 selector) external {
        allowFunction(stateId, selector);
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
}
