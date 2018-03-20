pragma solidity 0.4.19;


/// @title A library for implementing a generic state machine pattern.
library StateMachineLib {

    event LogTransition(bytes32 indexed stateId, uint256 blockNumber);

    struct State {
        // The id of the next state
        bytes32 nextStateId;

        // The identifiers for the available functions in each state
        mapping(bytes4 => bool) allowedFunctions;

        function() internal[] transitionCallbacks;
        function(bytes32) internal returns(bool)[] startConditions;
    }

    struct StateMachine {
        // The current state id
        bytes32 currentStateId;

        // Checks if a state id is valid
        mapping(bytes32 => bool) validState;

        // Maps state ids to their State structs
        mapping(bytes32 => State) states;
    }

    /// @dev Creates and sets the initial state. It has to be called before creating any transitions.
    /// @param stateId The id of the (new) state to set as initial state.
    function setInitialState(StateMachine storage stateMachine, bytes32 stateId) public {
        require(stateMachine.currentStateId == 0);
        stateMachine.validState[stateId] = true;
        stateMachine.currentStateId = stateId;
    }

    /// @dev Creates a transition from 'fromId' to 'toId'. If fromId already had a nextStateId, it deletes the now unreachable state.
    /// @param fromId The id of the state from which the transition begins.
    /// @param toId The id of the state that will be reachable from "fromId".
    function createTransition(StateMachine storage stateMachine, bytes32 fromId, bytes32 toId) public {
        require(stateMachine.validState[fromId]);

        State storage from = stateMachine.states[fromId];

        // Invalidate the state that won't be reachable any more
        if (from.nextStateId != 0) {
            stateMachine.validState[from.nextStateId] = false;
            delete stateMachine.states[from.nextStateId];
        }

        from.nextStateId = toId;
        stateMachine.validState[toId] = true;
    }

    /// @dev Creates the given states.
    /// @param stateIds Array of state ids.
    function setStates(StateMachine storage stateMachine, bytes32[] stateIds) public {
        require(stateIds.length > 0);

        setInitialState(stateMachine, stateIds[0]);

        for (uint256 i = 1; i < stateIds.length; i++) {
            createTransition(stateMachine, stateIds[i - 1], stateIds[i]);
        }
    }

    /// @dev Goes to the next state if posible (if the next state is valid)
    function goToNextState(StateMachine storage stateMachine) public {
        State storage currentState = stateMachine.states[stateMachine.currentStateId];

        bytes32 nextStateId = currentState.nextStateId;
        require(stateMachine.validState[nextStateId]);

        stateMachine.currentStateId = nextStateId;

        State storage nextState = stateMachine.states[nextStateId];

        for (uint256 i = 0; i < nextState.transitionCallbacks.length; i++) {
            nextState.transitionCallbacks[i]();
        }

        LogTransition(nextStateId, block.number);
    }

    /// @dev Checks if the a function is allowed in the current state.
    /// @param selector A function selector (bytes4[keccak256(functionSignature)])
    /// @return true If the function is allowed in the current state
    function checkAllowedFunction(StateMachine storage stateMachine, bytes4 functionSelector) public constant returns(bool) {
        return stateMachine.states[stateMachine.currentStateId].allowedFunctions[functionSelector];
    }

    /// @dev Allow a function in the given state.
    /// @param stateId The id of the state
    /// @param selector A function selector (bytes4[keccak256(functionSignature)])
    function allowFunction(StateMachine storage stateMachine, bytes32 stateId, bytes4 functionSelector) public {
        require(stateMachine.validState[stateId]);
        stateMachine.states[stateId].allowedFunctions[functionSelector] = true;
    }

    ///@dev add a function returning a boolean as a start condition for a state
    ///@param stateId The ID of the state to add the condition for
    ///@param condition Start condition function - returns true if a start condition (for a given state ID) is met
    function addStartCondition(StateMachine storage stateMachine, bytes32 stateId, function(bytes32) internal returns(bool) condition) internal {
        require(stateMachine.validState[stateId]);
        stateMachine.states[stateId].startConditions.push(condition);
    }

    ///@dev add a callback function for a state
    ///@param stateId The ID of the state to add a callback function for
    ///@param callback The callback function to add (if the state is valid)
    function addCallback(StateMachine storage stateMachine, bytes32 stateId, function() internal callback) internal {
        require(stateMachine.validState[stateId]);
        stateMachine.states[stateId].transitionCallbacks.push(callback);
    }

    ///@dev transitions the state machine into the state it should currently be in
    ///@dev by taking into account the current conditions and how many further transitions can occur 
    function conditionalTransitions(StateMachine storage stateMachine) public {

        bytes32 nextStateId = stateMachine.states[stateMachine.currentStateId].nextStateId;

        while (stateMachine.validState[nextStateId]) {
            StateMachineLib.State storage nextState = stateMachine.states[nextStateId];
            // If one of the next state's conditions is met, go to this state and continue
            bool stateChanged = false;
            for (uint256 i = 0; i < nextState.startConditions.length; i++) {
                if (nextState.startConditions[i](nextStateId)) {
                    goToNextState(stateMachine);
                    nextStateId = nextState.nextStateId;
                    stateChanged = true;
                    break;
                }
            }
            // If none of the next state's conditions are met, then we are in the right current state
            if (!stateChanged) break;
        }
    }
}
