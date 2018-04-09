pragma solidity 0.4.19;

import "./StateMachine.sol";


/// @title A contract that implements the state machine pattern and adds time dependant transitions.
contract TimedStateMachine is StateMachine {

    event LogSetStateStartTime(bytes32 indexed _stateId, uint256 _startTime);

    // Stores the start timestamp for each state (the value is 0 if the state doesn't have a start timestamp).
    mapping(bytes32 => uint256) private startTime;

    /// @dev Returns the timestamp for the given state id.
    /// @param _stateId The id of the state for which we want to set the start timestamp.
    function getStateStartTime(bytes32 _stateId) public view returns(uint256) {
        return startTime[_stateId];
    }

    /// @dev Sets the starting timestamp for a state.
    /// @param _stateId The id of the state for which we want to set the start timestamp.
    /// @param _timestamp The start timestamp for the given state. It should be bigger than the current one.
    function setStateStartTime(bytes32 _stateId, uint256 _timestamp) internal {
        require(block.timestamp < _timestamp);

        if (startTime[_stateId] == 0) {
            addStartCondition(_stateId, hasStartTimePassed);
        }

        startTime[_stateId] = _timestamp;

        LogSetStateStartTime(_stateId, _timestamp);
    }

    function hasStartTimePassed(bytes32 _stateId) internal returns(bool) {
        return startTime[_stateId] <= block.timestamp;
    }

}
