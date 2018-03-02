pragma solidity 0.4.19;

import "./StateMachine.sol";


/// @title A contract that implements the state machine pattern and adds time dependant transitions.
contract TimedStateMachine is StateMachine {

    event LogSetStageStartTime(bytes32 indexed stageId, uint256 startTime);

    // Stores the start timestamp for each stage (the value is 0 if the stage doesn't have a start timestamp).
    mapping(bytes32 => uint256) internal startTime;

    /// @dev This function overrides the startConditions function in the parent contract in order to enable automatic transitions that depend on the timestamp.
    function startConditions(bytes32 stageId) internal constant returns(bool) {
        // Get the startTime for stage
        uint256 start = startTime[stageId];
        // If the startTime is set and has already passed, return true.
        if (start != 0 && block.timestamp > start) return true;
        return super.startConditions(stageId);
    }

    /// @dev Sets the starting timestamp for a stage.
    /// @param stageId The id of the stage for which we want to set the start timestamp.
    /// @param timestamp The start timestamp for the given stage. It should be bigger than the current one.
    function setStageStartTime(bytes32 stageId, uint256 timestamp) internal {
        require(state.validStage[stageId]);
        require(timestamp > block.timestamp);

        startTime[stageId] = timestamp;
        LogSetStageStartTime(stageId, timestamp);
    }

    /// @dev Returns the timestamp for the given stage id.
    /// @param stageId The id of the stage for which we want to set the start timestamp.
    function getStageStartTime(bytes32 stageId) public view returns(uint256) {
        return startTime[stageId];
    }
}
