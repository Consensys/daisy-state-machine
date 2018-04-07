pragma solidity 0.4.19;

import "./StateMachine.sol";

/// @title A contract that implements the state machine pattern and adds time dependant transitions.
contract TimedStateMachine is StateMachine {

    event LogSetTransitionStartTime(bytes32 indexed _startState, bytes32 indexed _endTime, uint256 _startTime);

    // Stores the start timestamp for each state (the value is 0 if the state doesn't have a start timestamp).
    mapping(bytes32 => uint256) private transitionStartTime;

    /// @dev Returns the timestamp for the given state id.
    /// @param _fromStateId The id of the start state of the transition.
    /// @param _toStateId The id of the end state of the transition.
    function getTransitionStartTime(bytes32 _fromStateId, bytes32 _toStateId) public view returns(uint256) {
        bytes32 transitionId = getTransitionId(_fromStateId, _toStateId);
        return transitionStartTime[transitionId];
    }

    /// @dev Sets the starting timestamp for a state.
    /// @param _fromStateId The id of the start state of the transition.
    /// @param _toStateId The id of the end state of the transition.
    /// @param _timestamp The start timestamp for the given state. It should be bigger than the current one.
    function setTransitionStartTime(bytes32 _fromStateId, bytes32 _toStateId, uint256 _timestamp) internal {
        require(block.timestamp < _timestamp);

        bytes32 transitionId = getTransitionId(_fromStateId, _toStateId);           
        if (transitionStartTime[transitionId] == 0) {
            if (!transitionExists[transitionId]) {
                createTransition(_fromStateId, _toStateId);
            }
            addStartCondition(_fromStateId, _toStateId, hasStartTimePassed);
        }

        transitionStartTime[transitionId] = _timestamp;

        LogSetTransitionStartTime(_fromStateId, _toStateId, _timestamp);
    }

    function hasStartTimePassed(bytes32 _toStateId) internal returns(bool) {
        bytes32 transitionId = getTransitionId(currentStateId, _toStateId);
        return transitionStartTime[transitionId] <= block.timestamp;
    }

}