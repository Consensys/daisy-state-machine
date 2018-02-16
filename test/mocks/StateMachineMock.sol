pragma solidity 0.4.19;

import "../../contracts/StateMachine.sol";


contract StateMachineMock is StateMachine {
    bytes4 public dummyFunctionSelector = this.dummyFunction.selector;

    bytes32 public constant STAGE0 = "STAGE0";
    bytes32 public constant STAGE1 = "STAGE1";
    bytes32 public constant STAGE2 = "STAGE2";
    bytes32 public constant STAGE3 = "STAGE3";
    bool public requiredDummy = true;

    function StateMachineMock() public { 
        state.setInitialStage(STAGE0);
        state.createTransition(STAGE0, STAGE1);
        state.createTransition(STAGE1, STAGE2);
        state.createTransition(STAGE2, STAGE3);
    }

    function dummyFunction() public checkAllowed {
    }

    // Helper to test creating transitions
    function createTransition(bytes32 fromId, bytes32 toId) public {
        state.createTransition(fromId, toId);
    }

    // Helper to test going to next stage
    function goToNextStageHelper() public {
        goToNextStage();
    }

    // Helper to test allowing a function
    function allowFunction(bytes32 stageId, bytes4 selector) public {
        state.allowFunction(stageId, selector);
    }

    // Helper to test required conditions
    function setRequired(bool required) public {
        requiredDummy = required;
    }

    function requiredConditions(bytes32 stageId) internal constant returns(bool) {
        if (stageId == STAGE3 && !requiredDummy) return false;
        return true;
    }


}
