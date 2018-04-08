pragma solidity 0.4.19;

import "../../contracts/StateMachine.sol";


contract StateMachineMock is StateMachine {
    bytes4 public dummyFunctionSelector = this.dummyFunction.selector;

    bool public condition = false;
    bool public transitionEffectCalled = false;

    function StateMachineMock() public { 
    }

    function setInitialStateHelper(bytes32 _initialState) public {
        setInitialState(_initialState);
    }

    function createTransitionHelper(bytes32 _fromStateId, bytes32 _toStateId) public {
        createTransition(_fromStateId, _toStateId);
    }
 

    function dummyFunction() public checkAllowed {
    }

    function dummyCondition(bytes32) internal returns(bool) {
        return true;
    }

    function dummyVariableCondition(bytes32) internal returns(bool) {
        return condition;
    }

    function dummyTransitionEffect() internal {
        transitionEffectCalled = true;
    }

    // Helper to test going to next state
    function goToNextStateHelper(bytes32 _stateId) public {
        goToNextState(_stateId);
    }

    // Sets the dummy condition for a state
    function setDummyCondition(bytes32 _fromStateId, bytes32 _toStateId) public {
        addStartCondition(_fromStateId, _toStateId, dummyCondition);
    }

    function setCondition(bool _condition) public {
        condition = _condition;
    }

    // Sets the dummy transitionEffect condition for a state
    function setDummyVariableCondition(bytes32 _fromStateId, bytes32 _toStateId) public {
        addStartCondition(_fromStateId, _toStateId, dummyVariableCondition);
    }

    // Sets the dummy transitionEffect for a state
    function setDummyTransitionEffect(bytes32 _fromStateId, bytes32 _toStateId) public {
        addTransitionEffect(_fromStateId, _toStateId, dummyTransitionEffect);
    }

    // Helper to test allowing a function
    function allowFunctionHelper(bytes32 _stateId, bytes4 _selector) public {
        allowFunction(_stateId, _selector);
    }

    function conditionalTransitionHelper() public {
        conditionalTransitions();
    }

}
