pragma solidity 0.4.19;

import "../../contracts/TimedStateMachine.sol";


contract TimedStateMachineMock is TimedStateMachine {
    bytes32 public constant STAGE0 = "STAGE0";
    bytes32 public constant STAGE1 = "STAGE1";
    bytes32 public constant STAGE2 = "STAGE2";
    bytes32 public constant STAGE3 = "STAGE3";

    function TimedStateMachineMock() public { 
        state.setInitialStage(STAGE0);
        state.createTransition(STAGE0, STAGE1);
        state.createTransition(STAGE1, STAGE2);
        state.createTransition(STAGE2, STAGE3);
    }

    // Helper to set the stage start time
    function setStageStartTimeHelper(bytes32 stageId, uint256 timestamp) public {
        setStageStartTime(stageId, timestamp);
    }
}
