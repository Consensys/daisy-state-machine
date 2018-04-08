pragma solidity 0.4.19;

import "../../contracts/TimedStateMachine.sol";


contract TimedStateMachineMock is TimedStateMachine {
    bytes32 public constant STATE0 = "STATE0";
    bytes32 public constant STATE1 = "STATE1";
    bytes32 public constant STATE2 = "STATE2";
    bytes32 public constant STATE3 = "STATE3";

    function TimedStateMachineMock() public { 
    }

    // Helper to set the state start time
    function setTransitionStartTimeHelper(bytes32 _fromId, bytes32 _toId, uint256 _timestamp) public {
        setTransitionStartTime(_fromId, _toId, _timestamp);
    }


    function conditionalTransitionHelper() public {
        conditionalTransitions();
    }

    function setInitialStateHelper(bytes32 _initialState) public {
        setInitialState(_initialState);
    }

    function createTransitionHelper(bytes32 _fromStateId, bytes32 _toStateId) public {
        createTransition(_fromStateId, _toStateId);
    }
}
