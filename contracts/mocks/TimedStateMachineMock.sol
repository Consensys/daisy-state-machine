pragma solidity 0.4.19;

import "../../contracts/TimedStateMachine.sol";


contract TimedStateMachineMock is TimedStateMachine {
    bytes32 public constant STATE0 = "STATE0";
    bytes32 public constant STATE1 = "STATE1";
    bytes32 public constant STATE2 = "STATE2";
    bytes32 public constant STATE3 = "STATE3";

    function TimedStateMachineMock() public { 
        createTransition(STATE0, STATE1);
        createTransition(STATE0, STATE2);
        createTransition(STATE1, STATE2);
        createTransition(STATE1, STATE3);
    }

    // Helper to set the state start time
    function setTransitionStartTimeHelper(bytes32 _fromId, bytes32 _toId, uint256 _timestamp) public {
        setTransitionStartTime(_fromId, _toId, _timestamp);
    }
}
