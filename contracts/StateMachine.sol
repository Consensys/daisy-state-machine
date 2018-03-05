pragma solidity 0.4.19;

import "./StateMachineLib.sol";


contract StateMachine {
    using StateMachineLib for StateMachineLib.State;

    struct CallbackWrapper {
        bool valid;
        function() internal callback;
    }

    struct ConditionWrapper {
        bool valid;
        // TODO: make the condition a 'view' once solidity-coverage is fixed.
        function() internal returns(bool) condition;
    }

    event LogTransition(bytes32 indexed stageId, uint256 blockNumber);

    mapping(bytes32 => CallbackWrapper) private callbacks;
    mapping(bytes32 => ConditionWrapper) private conditions;

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
            if (startConditions(nextId)) {
                state.goToNextStage();
                nextId = next.nextId;
            } else {
                break;
            }
        }
    }

    /// @dev Goes to the next stage if required conditions are made.
    function goToNextStage() internal {
        state.goToNextStage();
    }

    /// @dev Sets the start conditions for a stage
    function setStageStartCondition(bytes32 stageId, function() internal returns(bool) condition) internal {
        require(state.validStage[stageId]);
        conditions[stageId] = ConditionWrapper(true, condition);
    }

    /// @dev Determines whether the conditions for transitioning to the given stage are met.
    /// @return true if the conditions are met for the given stageId. False by default (must override in child contracts).
    function startConditions(bytes32 stageId) internal constant returns(bool) {
        ConditionWrapper storage wrapper = conditions[stageId];

        if (wrapper.valid) return wrapper.condition();

        return false;
    }

    /// @dev Registers a callback for a stage transition
    function setStageCallback(bytes32 stageId, function() internal callback) internal {
        require(state.validStage[stageId]);
        callbacks[stageId] = CallbackWrapper(true, callback);
    }

    /// @dev Callback called when there is a stage transition.
    function onTransition(bytes32 stageId) internal {
        CallbackWrapper storage wrapper = callbacks[stageId];

        if (wrapper.valid) wrapper.callback();

        LogTransition(stageId, block.number);
    }
}
