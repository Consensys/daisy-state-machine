pragma solidity 0.4.19;

import "./StateMachine.sol";


/// @title A contract that implements the state machine pattern and adds time dependant transitions.
contract TimedStateMachine is StateMachine {

    event LogSetTransitionTime(bytes32 indexed _startState, bytes32 indexed _endState, uint256 _timestamp);
    event LogChangeTransitionTime(bytes32 indexed _startState, bytes32 indexed _endState, uint256 _timestamp);

    // Stores the start timestamp for each state (the value is 0 if the state doesn't have a start timestamp).
    mapping(bytes32 => mapping(bytes32 => uint256)) internal transitionTimes;

    Transition timedTransition;
    

    /// @dev Sets the timestamp for a transition.
    /// @param _stateId The id of the state for which we want to set the start timestamp.
    /// @param _timestamp The start timestamp for the given state. It should be bigger than the current one.
    function createTimedTransition(bytes32 _startState, bytes32 _endState, uint256 _timestamp, function() internal _transitionEffect) internal {
        require(block.timestamp < _timestamp);
        require(transitionTimes[_startState][_endState] == 0);

        transitionTimes[_startState][_endState] = _timestamp;
        timedTransition = Transition(_startState, _endState, _transitionEffect, hasTransitionTimePassed);
        createTransition(timedTransition);
        LogSetTransitionTime(_startState, _endState, _timestamp);
    }

    function updateTransitionTime(bytes32 _startState, bytes32 _endState, uint256 _timestamp) internal {
        require(transitionTimes[_startState][_endState] != 0);
        require(block.timestamp < _timestamp);
        transitionTimes[_startState][_endState] = _timestamp;

    }

    /// @dev Returns the timestamp for the given state id.
    /// @param _stateId The id of the state for which we want to set the start timestamp.
    function getTransitionTime(bytes32 _startState, bytes32 _endState) public view returns(uint256) {
        return transitionTimes[_startState][_endState];
    }

    function hasTransitionTimePassed(bytes32 _stateId) internal returns(bool) {
        return transitionTimes[currentStateId][_stateId] <= block.timestamp;
    }

}
