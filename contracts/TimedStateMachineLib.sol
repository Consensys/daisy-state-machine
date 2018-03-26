pragma solidity 0.4.19;

import "./StateMachineLib.sol";

/// @title A library for implementing a generic timed state machine pattern.
library TimedStateMachineLib {

    event LogSetStateStartTime(bytes32 indexed _stateId, uint256 _startTime);
    event LogChangeStateStartTime(bytes32 indexed _stateId, uint256 _startTime);

    // Stores the start timestamp for each state (the value is 0 if the state doesn't have a start timestamp).
    mapping(bytes32 => uint256) internal startTime;

    /// @dev Sets the starting timestamp for a state.
    /// @param _stateId The id of the state for which we want to set the start timestamp.
    /// @param _timestamp The start timestamp for the given state. It should be bigger than the current time.
    function setStateStartTime(StateMachineLib.StateMachine stateMachine, bytes32 _stateId, uint256 _timestamp) public {
        require(block.timestamp < _timestamp);
        require(startTime[_stateId] == 0);

        startTime[_stateId] = _timestamp;
        stateMachine.addStartCondition(_stateId, hasStartTimePassed);
        LogSetStateStartTime(_stateId, _timestamp);

    }

    /// @dev updates the starting timestamp for a state.
    /// @param _stateId The id of the state for which we want to change the start timestamp.
    /// @param _timestamp The new start timestamp for the given state.
    function changeStateStartTime(StateMachineLib.StateMachine stateMachine, bytes32 _stateId, uint256 _timestamp) public {
        require(stateMachine.validState[_stateId]);
        require(startTime[_stateId] != 0);
        require(block.timestamp < _timestamp);

        startTime[_stateId] = _timestamp;
        LogChangeStateStartTime(_stateId, _timestamp);

    }

    /// @dev Returns the timestamp for the given state id.
    /// @param _stateId The id of the state for which we want to set the start timestamp.
    function getStateStartTime(StateMachineLib.StateMachine stateMachine, bytes32 _stateId) public view returns(uint256) {
        return startTime[_stateId];
    }

    // @dev determines whether the starttime for a specific state has passed
    /// @param _stateId The state ID of the state in question
    function hasStartTimePassed(StateMachineLib.StateMachine stateMachine, bytes32 _stateId) public returns(bool) {
        return startTime[_stateId] <= block.timestamp;
    }

}