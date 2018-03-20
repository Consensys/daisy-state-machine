pragma solidity 0.4.19;


/// @title A library for implementing a generic state machine pattern.
library StateMachineLib {

    event LogTransition(bytes32 indexed stateId, uint256 blockNumber);

    struct State {
        // The id of the next state
        bytes32 nextId;

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
    function setInitialState(StateMachine storage self, bytes32 stateId) public {
        require(self.currentStateId == 0);
        self.validState[stateId] = true;
        self.currentStateId = stateId;
    }

    /// @dev Creates a transition from 'fromId' to 'toId'. If fromId already had a nextId, it deletes the now unreachable state.
    /// @param fromId The id of the state from which the transition begins.
    /// @param toId The id of the state that will be reachable from "fromId".
    function createTransition(StateMachine storage self, bytes32 fromId, bytes32 toId) public {
        require(self.validState[fromId]);

        State storage from = self.states[fromId];

        // Invalidate the state that won't be reachable any more
        if (from.nextId != 0) {
            self.validState[from.nextId] = false;
            delete self.states[from.nextId];
        }

        from.nextId = toId;
        self.validState[toId] = true;
    }

    /// @dev Creates the given states.
    /// @param stateIds Array of state ids.
    function setStates(StateMachine storage self, bytes32[] stateIds) public {
        require(stateIds.length > 0);

        setInitialState(self, stateIds[0]);

        for (uint256 i = 1; i < stateIds.length; i++) {
            createTransition(self, stateIds[i - 1], stateIds[i]);
        }
    }

    /// @dev Goes to the next state if posible (if the next state is valid)
    function goToNextState(StateMachine storage self) public {
        State storage current = self.states[self.currentStateId];

        bytes32 nextId = current.nextId;
        require(self.validState[nextId]);

        self.currentStateId = current.nextId;

        State storage next = self.states[nextId];

        for (uint256 i = 0; i < next.transitionCallbacks.length; i++) {
            next.transitionCallbacks[i]();
        }

        LogTransition(nextId, block.number);
    }

    /// @dev Checks if the a function is allowed in the current state.
    /// @param selector A function selector (bytes4[keccak256(functionSignature)])
    /// @return true If the function is allowed in the current state
    function checkAllowedFunction(StateMachine storage self, bytes4 selector) public constant returns(bool) {
        return self.states[self.currentStateId].allowedFunctions[selector];
    }

    /// @dev Allow a function in the given state.
    /// @param stateId The id of the state
    /// @param selector A function selector (bytes4[keccak256(functionSignature)])
    function allowFunction(StateMachine storage self, bytes32 stateId, bytes4 selector) public {
        require(self.validState[stateId]);
        self.states[stateId].allowedFunctions[selector] = true;
    }

    function addStartCondition(StateMachine storage self, bytes32 stateId, function(bytes32) internal returns(bool) condition) internal {
        require(self.validState[stateId]);
        self.states[stateId].startConditions.push(condition);
    }

    function addCallback(StateMachine storage self, bytes32 stateId, function() internal callback) internal {
        require(self.validState[stateId]);
        self.states[stateId].transitionCallbacks.push(callback);
    }

    function conditionalTransitions(StateMachine storage self) public {

        bytes32 nextId = self.states[self.currentStateId].nextId;

        while (self.validState[nextId]) {
            StateMachineLib.State storage next = self.states[nextId];
            // If one of the next state's condition is true, go to next state and continue
            bool stateChanged = false;
            for (uint256 i = 0; i < next.startConditions.length; i++) {
                if (next.startConditions[i](nextId)) {
                    goToNextState(self);
                    nextId = next.nextId;
                    stateChanged = true;
                    break;
                }
            }

            if (!stateChanged) break;
        }
    }
}
