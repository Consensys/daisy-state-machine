pragma solidity 0.4.19;

import "./StateMachine.sol";


/// @title A contract that implements the state machine pattern and adds time dependant transitions.
contract TimedStateMachine is StateMachine {

    event LogSetStageStartTime(bytes32 indexed stageId, uint256 startTime);

    // Stores the start timestamp for each stage (the value is 0 if the stage doesn't have a start timestamp).
    mapping(bytes32 => uint256) internal startTime;

    /// @dev Sets the starting timestamp for a stage.
    /// @param stageId The id of the stage for which we want to set the start timestamp.
    /// @param timestamp The start timestamp for the given stage. It should be bigger than the current one.
    function setStageStartTime(bytes32 stageId, uint256 timestamp) internal {
        require(block.timestamp < timestamp);
        require(startTime[stageId] == 0);
        startTime[stageId] = timestamp;
        state.addStartCondition(stageId, hasStartTimePassed);

        LogSetStageStartTime(stageId, timestamp);
    }

    function changeStageStartTime(bytes32 stageId, uint256 timestamp) internal {
        require(block.timestamp < timestamp);
        require(startTime[stageId] != 0);
        startTime[stageId] = timestamp;
    }

    /// @dev Returns the timestamp for the given stage id.
    /// @param stageId The id of the stage for which we want to set the start timestamp.
    function getStageStartTime(bytes32 stageId) public view returns(uint256) {
        return startTime[stageId];
    }

    function hasStartTimePassed(bytes32 stageId) internal returns(bool) {
        return startTime[stageId] <= block.timestamp;
    }

}
