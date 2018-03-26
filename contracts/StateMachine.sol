pragma solidity 0.4.19;

import "./StateMachineLib.sol";


contract StateMachine {
    using StateMachineLib for StateMachineLib.StateMachine;
    StateMachineLib.StateMachine internal stateMachine;

    /* This modifier performs the conditional transitions and checks that the function 
     * to be executed is allowed in the current State
     */
    modifier checkAllowed {
        stateMachine.conditionalTransitions();
        require(stateMachine.checkAllowedFunction(msg.sig));
        _;
    }

    function conditionalTransitions() public {
        stateMachine.conditionalTransitions();
    }

    function getCurrentStateId() public returns(bytes32) {
        return stateMachine.currentStateId;
    }
}