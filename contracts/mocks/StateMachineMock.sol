pragma solidity 0.4.19;

import "../../contracts/StateMachine.sol";


contract StateMachineMock is StateMachine {
    bytes4 public dummyFunctionSelector = this.dummyFunction.selector;

    bool public condition = false;
    bool public callbackCalled = false;

    function StateMachineMock() public { 
    }

    function setStagesHelper(bytes32[] _stages) public {
        state.setStages(_stages);
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
        state.createTransition(fromId, toId);
    }

    // Helper to test going to next stage
    function goToNextStageHelper() public {
        state.goToNextStage();
    }

    // Sets the dummy condition for a stage
    function setDummyCondition(bytes32 stageId) public {
        state.addStartCondition(stageId, dummyCondition);
    }

    function setCondition(bool _condition) public {
        condition = _condition;
    }

    // Sets the dummy callback condition for a stage
    function setDummyVariableCondition(bytes32 stageId) public {
        state.addStartCondition(stageId, dummyVariableCondition);
    }

    // Sets the dummy callback for a stage
    function setDummyCallback(bytes32 stageId) public {
        state.addCallback(stageId, dummyCallback);
    }

    // Helper to test allowing a function
    function allowFunction(bytes32 stageId, bytes4 selector) public {
        state.allowFunction(stageId, selector);
    }

}
