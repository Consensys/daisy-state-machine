pragma solidity 0.4.19;

import "./StateMachineLib.sol";


contract StateMachine {
    using StateMachineLib for StateMachineLib.State;
    StateMachineLib.State internal state;

    /* This modifier performs the conditional transitions and checks that the function 
     * to be executed is allowed in the current stage
     */
    modifier checkAllowed {
        state.conditionalTransitions();
        require(state.checkAllowedFunction(msg.sig));
        _;
    }

    function conditionalTransitions() public {
        state.conditionalTransitions();
    }

    function getCurrentStageId() public returns(bytes32) {
        return state.currentStageId;
    }
}
