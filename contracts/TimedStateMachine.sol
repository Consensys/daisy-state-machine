pragma solidity 0.4.19;

import "./StateMachine.sol";


/// @title A contract that implements the state machine pattern and adds time dependant transitions.
contract TimedStateMachine is StateMachine {

    event LogSetStateStartTime(bytes32 indexed stateId, uint256 startTime);

    // Stores the start timestamp for each state (the value is 0 if the state doesn't have a start timestamp).
    mapping(bytes32 => uint256) internal startTime;

    /// @dev Sets the starting timestamp for a state.
    /// @param stateId The id of the state for which we want to set the start timestamp.
    /// @param timestamp The start timestamp for the given state. It should be bigger than the current one.
    function setStateStartTime(bytes32 stateId, uint256 timestamp) internal {
        require(block.timestamp < timestamp);
        require(startTime[stateId] == 0);
        startTime[stateId] = timestamp;
        stateMachine.addStartCondition(stateId, hasStartTimePassed);

        LogSetStateStartTime(stateId, timestamp);
    }

    function changeStateStartTime(bytes32 stateId, uint256 timestamp) internal {
        require(block.timestamp < timestamp);
        require(startTime[stateId] != 0);
        startTime[stateId] = timestamp;
    }

    /// @dev Returns the timestamp for the given state id.
    /// @param stateId The id of the state for which we want to set the start timestamp.
    function getStateStartTime(bytes32 stateId) public view returns(uint256) {
        return startTime[stateId];
    }

    function hasStartTimePassed(bytes32 stateId) internal returns(bool) {
        return startTime[stateId] <= block.timestamp;
    }

}