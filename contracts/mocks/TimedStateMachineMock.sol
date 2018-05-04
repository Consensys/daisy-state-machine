pragma solidity 0.4.23;

import "../../contracts/TimedStateMachine.sol";


contract TimedStateMachineMock is TimedStateMachine {
    bytes32 public constant STATE0 = "STATE0";
    bytes32 public constant STATE1 = "STATE1";
    bytes32 public constant STATE2 = "STATE2";
    bytes32 public constant STATE3 = "STATE3";
    bytes32[] public states = [STATE0, STATE1, STATE2, STATE3];

    constructor() public { 
        setStates(states);
    }

    // Helper to set the state start time
    function setStateStartTimeHelper(bytes32 stateId, uint256 timestamp) public {
        setStateStartTime(stateId, timestamp);
    }

}
