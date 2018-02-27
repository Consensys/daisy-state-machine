pragma solidity 0.4.19;

import "./StateMachineLib.sol";


contract StateMachine {
    using StateMachineLib for StateMachineLib.State;

    struct CallbackWrapper {
      bool valid;
      function() internal callback;
    }

    event LogTransition(bytes32 indexed stageId, uint256 blockNumber);

    mapping(bytes32 => CallbackWrapper) onTransitionCallbacks;

    StateMachineLib.State internal state;

    /* This modifier performs the conditional transitions and checks that the function 
     * to be executed is allowed in the current stage
     */
    modifier checkAllowed {
        conditionalTransitions();
        require(state.checkAllowedFunction(msg.sig));
        _;
    }

    function StateMachine() public {
        // Register the startConditions function and the onTransition callback
        state.onTransition = onTransition;
    }

    /// @dev Gets the current stage id.
    /// @return The current stage id.
    function getCurrentStageId() public view returns(bytes32) {
        return state.currentStageId;
    }

    /// @dev Performs conditional transitions. Can be called by anyone.
    function conditionalTransitions() public {

        bytes32 nextId = state.stages[state.currentStageId].nextId;

        while (state.validStage[nextId]) {
            StateMachineLib.Stage storage next = state.stages[nextId];
            // If the next stage's condition is true, go to next stage and continue
            if (startConditions(nextId) && requiredConditions(nextId)) {
                state.goToNextStage();
                nextId = next.nextId;
            } else {
                break;
            }
        }
    }

    /// @dev Goes to the next stage if required conditions are made.
    function goToNextStage() internal {
        require(requiredConditions(state.stages[state.currentStageId].nextId));
        state.goToNextStage();
    }

    /// @dev Determines whether the conditions for transitioning to the given stage are met.
    /// @return true if the conditions are met for the given stageId. False by default (must override in child contracts).
    function startConditions(bytes32) internal constant returns(bool) {
        return false;
    }

    /// @dev Determines if it is possible to transition to the given stage.
    /// @return true if it is possible to go to the given stage. True by default (must override in child contracts).
    function requiredConditions(bytes32) internal constant returns(bool) {
        return true;
    }

    /// @dev Registers a callback for a stage transition
    function setStageCallback(bytes32 stageId, function() internal callback) internal {
        CallbackWrapper storage cb = onTransitionCallbacks[stageId];
        cb.valid = true;
        cb.callback = callback;
    }

    /// @dev Callback called when there is a stage transition.
    function onTransition(bytes32 stageId) internal {
        CallbackWrapper storage cb = onTransitionCallbacks[stageId];

        if (cb.valid) {
            cb.callback();
        }

        LogTransition(stageId, block.number);
    }
}
