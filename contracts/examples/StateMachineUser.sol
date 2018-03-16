pragma solidity 0.4.19;

import "../TimedStateMachine.sol";


contract StateMachineUser is TimedStateMachine {

    bytes32 constant STAGE1 = "stage1";
    bytes32 constant STAGE2 = "stage2";
    bytes32 constant STAGE3 = "stage3";
    bytes32 constant STAGE4 = "stage4";
    bytes32[] stages = [STAGE1, STAGE2, STAGE3, STAGE4];

    function StateMachineUser() public {
        setupStages();
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
        state.setStages(stages);

        state.allowFunction(STAGE1, this.foo.selector);
        state.allowFunction(STAGE2, this.bar.selector);
        state.allowFunction(STAGE3, 0); // Allow fallback function

        setStageCallback(STAGE1, onStage1);
        setStageCallback(STAGE2, onStage2);
        setStageCallback(STAGE3, onStage3);

        setStageStartTime(STAGE2, now + 2 weeks);
        setStageStartTime(STAGE3, now + 3 weeks);

        setStageStartCondition(STAGE4, shouldStage4Start);
    }

    // Callback when entering each stage
    function onStage1() internal { /* Do something */ }
    function onStage2() internal { /* Do something */ }
    function onStage3() internal { /* Do something */ }

    function shouldStage4Start() internal returns(bool) {
        return true;
    }

}
