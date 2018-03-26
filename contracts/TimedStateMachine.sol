pragma solidity 0.4.19;

import "./StateMachine.sol";
import "./StateMachineLib.sol";
import "./TimedStateMachineLib.sol";


/// @title A contract that implements the state machine pattern and adds time dependant transitions.
contract TimedStateMachine is StateMachine {
    using StateMachineLib for StateMachineLib.StateMachine;
    using TimedStateMachineLib for StateMachineLib.StateMachine;


}