pragma solidity 0.4.23;

import "../../contracts/TimedStateMachine.sol";


contract TimedStateMachineMock is TimedStateMachine {
    bytes32 public constant STATE0 = "STATE0";
    bytes32 public constant STATE1 = "STATE1";
    bytes32 public constant STATE2 = "STATE2";
    bytes32 public constant STATE3 = "STATE3";
    // bytes32[] public states = [STATE0, STATE1, STATE2, STATE3];

    constructor() public { 
        setInitialState(STATE0);
    }

    // Helper to set the state start time
    function setStartTimeHelper(bytes32 _fromId, bytes32 _toId, uint256 _timestamp) public {
        setStartTime(_fromId, _toId, _timestamp);
    }

}
