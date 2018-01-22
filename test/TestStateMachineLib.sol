pragma solidity 0.4.18;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/StateMachineLib.sol";

contract TestStateMachineLib {
    using StateMachineLib for StateMachineLib.State;

    bytes32 constant STAGE1 = "stage1";
    bytes32 constant STAGE2 = "stage2";
    bytes32 constant STAGE3 = "stage3";
    bytes32 constant STAGE4 = "stage4";

    // Stages that will override existing stages
    bytes32 constant STAGEOVERRIDE1 = "override1";
    bytes32 constant STAGEOVERRIDE2 = "override2";
    bytes32 constant STAGEOVERRIDE3 = "override3";

    StateMachineLib.State state;

    mapping(bytes32 => bool) dummyCallbackCalled;
    function dummyCallback(bytes32 stage) internal { 
        dummyCallbackCalled[stage] = true; 
    }

    function dummy() public pure {}

    function beforeEach() public {
        state.setInitialStage(STAGE1);
        state.createTransition(STAGE1, STAGE2);
        state.createTransition(STAGE2, STAGE3);
        state.createTransition(STAGE3, STAGE4);

        state.onTransition = dummyCallback;

        // dummyCallbackCalled[STAGE1] = false;
        dummyCallbackCalled[STAGE2] = false;
        dummyCallbackCalled[STAGE3] = false;
        dummyCallbackCalled[STAGE4] = false;
        dummyCallbackCalled[STAGEOVERRIDE1] = false;
        dummyCallbackCalled[STAGEOVERRIDE2] = false;
        dummyCallbackCalled[STAGEOVERRIDE3] = false;
    }

    function testStagesShouldBeValid() public {
        Assert.isTrue(state.validStage[STAGE1], "STAGE1 should be valid");
        Assert.isTrue(state.validStage[STAGE2], "STAGE2 should be valid");
        Assert.isTrue(state.validStage[STAGE3], "STAGE3 should be valid");
        Assert.isTrue(state.validStage[STAGE4], "STAGE4 should be valid");
    }

    function testTransitionsShouldWork() public {
        Assert.equal(state.currentStageId, STAGE1, "State should start at STAGE1");

        state.goToNextStage();
        Assert.equal(state.currentStageId, STAGE2, "State should have transitioned to STAGE2");

        state.goToNextStage();
        Assert.equal(state.currentStageId, STAGE3, "State should have transitioned to STAGE3");

        state.goToNextStage();
        Assert.equal(state.currentStageId, STAGE4, "State should have transitioned to STAGE4");
    }

    function testAllowedFunctions() public {
        bool allowed = false;
        bytes4 selector = this.dummy.selector;
        
        state.allowFunction(STAGE3, selector);

        allowed = state.checkAllowedFunction(selector);
        Assert.isFalse(allowed, "Dummy function should not be allowed in STAGE1");

        state.goToNextStage();
        allowed = state.checkAllowedFunction(selector);
        Assert.isFalse(allowed, "Dummy function should not be allowed in STAGE2");

        state.goToNextStage();
        allowed = state.checkAllowedFunction(selector);
        Assert.isTrue(allowed, "Dummy function should be allowed in STAGE3");

        state.goToNextStage();
        allowed = state.checkAllowedFunction(selector);
        Assert.isFalse(allowed, "Dummy function should not be allowed in STAGE4");
    }

    function testStageCallbacksShouldBeCalled() public {
        // Assert.isTrue(state.getStage(STAGE4).hasCallback, "setCallback should have set the 'hasCallback' bool of STAGE4 to true");

        Assert.isFalse(dummyCallbackCalled[STAGE2], "dummyCallback should not have been called before STAGE2");
        state.goToNextStage();
        Assert.isTrue(dummyCallbackCalled[STAGE2], "dummyCallback should have been called when entering STAGE2");

        Assert.isFalse(dummyCallbackCalled[STAGE3], "dummyCallback should not have been called before STAGE3");
        state.goToNextStage();
        Assert.isTrue(dummyCallbackCalled[STAGE3], "dummyCallback should have been called when entering STAGE3");

        Assert.isFalse(dummyCallbackCalled[STAGE4], "dummyCallback should not have been called before STAGE4");
        state.goToNextStage();
        Assert.isTrue(dummyCallbackCalled[STAGE4], "dummyCallback should have been called when entering STAGE4");
    }

    // Override stage 2 with 3 different stages
    function testOverridingStagesShouldWork() public {

        // We are "bypassing" STAGE2 by creating transitions STAGE1 -> STAGEOVERRIDE1 -> STAGEOVERRIDE2 -> STAGEOVERRIDE3 -> STAGE3
        state.createTransition(STAGE1, STAGEOVERRIDE1);
        state.createTransition(STAGEOVERRIDE1, STAGEOVERRIDE2);
        state.createTransition(STAGEOVERRIDE2, STAGEOVERRIDE3);
        state.createTransition(STAGEOVERRIDE3, STAGE3);

        Assert.isFalse(state.validStage[STAGE2], "STAGE2 should have become invalid");

        state.goToNextStage();
        Assert.equal(state.currentStageId, STAGEOVERRIDE1, "state should have transitioned to STAGEOVERRIDE1 (instead of STAGE2) from STAGE1");

        state.goToNextStage();
        Assert.equal(state.currentStageId, STAGEOVERRIDE2, "state should have transitioned to STAGEOVERRIDE2 from STAGEOVERRIDE1");

        state.goToNextStage();
        Assert.equal(state.currentStageId, STAGEOVERRIDE3, "state should have transitioned to STAGEOVERRIDE3 from STAGEOVERRIDE2");

        state.goToNextStage();
        Assert.equal(state.currentStageId, STAGE3, "state should have transitioned to STAGE3 from STAGEOVERRIDE3");

        Assert.isFalse(dummyCallbackCalled[STAGE2], "STAGE2's callback should not have been called");
    }
}

