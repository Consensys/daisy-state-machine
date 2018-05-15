pragma solidity 0.4.23;

import "./StateMachine.sol";


/// @title A contract that implements the state machine pattern and adds time dependant transitions.
contract TimedStateMachine is StateMachine {

    event StartTimeSet(bytes32 indexed _fromId, bytes32 indexed _toId, uint256 _startTime);

    // Stores the start timestamp for each state (the value is 0 if the state doesn't have a start timestamp).
    mapping(bytes32 => mapping(bytes32 => uint256)) private startTime;

    /// @dev Returns the timestamp for the given state id.
    /// @param _stateId The id of the state for which we want to set the start timestamp.
    function getStartTime(bytes32 _fromId, bytes32 _toId) public view returns(uint256) {
        return startTime[_fromId][_toId];
    }

    /// @dev Sets the starting timestamp for a state.
    /// @param _stateId The id of the state for which we want to set the start timestamp.
    /// @param _timestamp The start timestamp for the given state. It should be bigger than the current one.
    function setStartTime(bytes32 _fromId, bytes32 _toId, uint256 _timestamp) internal {
        require(block.timestamp < _timestamp);

        if (startTime[_fromId][_toId] == 0) {
            addStartCondition(_fromId, _toId, hasStartTimePassed);
        }

        startTime[_fromId][_toId] = _timestamp;

        emit StartTimeSet(_fromId, _toId, _timestamp);
    }

    function hasStartTimePassed(bytes32 _fromId, bytes32 _toId) internal returns(bool) {
        return startTime[_fromId][_toId] <= block.timestamp;
    }

}
