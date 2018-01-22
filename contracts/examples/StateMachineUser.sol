pragma solidity 0.4.18;

import "../TimedStateMachine.sol";


contract StateMachineUser is TimedStateMachine {

    bytes32 constant STAGE1 = "stage1";
    bytes32 constant STAGE2 = "stage2";
    bytes32 constant STAGE3 = "stage3";

    function StateMachineUser() public {
        setupStages();
        setStageStartTime(STAGE2, block.timestamp + 2 weeks);
        setStageStartTime(STAGE3, block.timestamp + 3 weeks);
    }

    /* The 'checkAllowed' modifier will perform conditional transitions
    and check that the function is allowed at the current stage */

    function() public checkAllowed {
        // Do something
    }
        
    function foo() public checkAllowed {
        // Do something
    }

    function bar() public checkAllowed {
        // Do something
    }

    function setupStages() internal {
        state.setInitialStage(STAGE1);
        state.createTransition(STAGE1, STAGE2);
        state.createTransition(STAGE2, STAGE3);

        state.allowFunction(STAGE1, this.foo.selector);
        state.allowFunction(STAGE2, this.bar.selector);
        state.allowFunction(STAGE3, 0); // Allow fallback function
    }

    // Callback when entering each stage
    function onStage1() internal { /* Do something */ }
    function onStage2() internal { /* Do something */ }
    function onStage3() internal { /* Do something */ }

    // Override from StateMachine.sol
    function onTransition(bytes32 stageId) internal {
        if (stageId == STAGE1) onStage1();
        else if (stageId == STAGE2) onStage2();
        else if (stageId == STAGE3) onStage3();
        super.onTransition(stageId);
    }
}
