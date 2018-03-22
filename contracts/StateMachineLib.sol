pragma solidity 0.4.19;


/// @title A library for implementing a generic state machine pattern.
library StateMachineLib {

    event LogTransition(bytes32 indexed _stateId, uint256 _blockNumber);

    struct State {
        // The id of the next state
        bytes32[] nextStateIds;
        mapping(bytes32 => bool) nextStates;

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
    function setInitialState(StateMachine storage _stateMachine, bytes32 _stateId) public {
        require(_stateMachine.currentStateId == 0);
        _stateMachine.validState[_stateId] = true;
        _stateMachine.currentStateId = _stateId;
    }

    /// @dev Creates a transition from 'fromId' to 'toId'.
    /// @dev this overloaded by the following function
    /// @param fromId The id of the state from which the transition begins.
    /// @param toId The id of the state that will be reachable from "fromId".
    function createTransition(StateMachine storage _stateMachine, bytes32 _fromId, bytes32 _toId) public {
        require(_stateMachine.validState[_fromId]);

        State storage from = _stateMachine.states[_fromId];
        _stateMachine.validState[_toId] = true;
        from.nextStates[_toId] = true;
        from.nextStateIds.push(_toId);
    }


    /// @dev Creates a transition from 'fromId' to each of the elements in 'toIds'.
    /// @dev this overloads the function above this
    /// @param fromId The id of the state from which the transition begins.
    /// @param toId The id of the state that will be reachable from "fromId".
    function createTransition(StateMachine storage _stateMachine, bytes32 _fromId, bytes32[] _toIds) public {
        require(_toIds.length > 0);
        require(_stateMachine.validState[_fromId]);

        State storage from = _stateMachine.states[_fromId];
        for (uint256 i = 0; i < _toIds.length; i++) {
            _stateMachine.validState[_toIds[i]] = true;
            from.nextStates[_toIds[i]] = true;
            from.nextStateIds.push(_toIds[i]);
        }
    }


    /// @dev Goes to the next state if posible (if the next state is valid)
    function goToNextState(StateMachine storage _stateMachine, bytes32 _nextStateId) internal {
        require(_stateMachine.validState[_nextStateId]);
        require(_stateMachine.states[_stateMachine.currentStateId].nextStates[_nextStateId]);
            
        _stateMachine.currentStateId = _nextStateId;
        function() internal[] storage transitionCallbacks = _stateMachine.states[_nextStateId].transitionCallbacks;
        for (uint256 j = 0; j < transitionCallbacks.length; j++) {
            transitionCallbacks[j]();
        }
             
        emit LogTransition(_nextStateId, block.number);
        }
    }

    /// @dev Checks if a function is allowed in the current state.
    /// @param functionSelector A function selector (bytes4[keccak256(functionSignature)])
    /// @return true If the function is allowed in the current state
    function checkAllowedFunction(StateMachine storage _stateMachine, bytes4 _functionSelector) public constant returns(bool) {
        require (_stateMachine.validState[_stateMachine.currentStateId]);
        return _stateMachine.states[_stateMachine.currentStateId].allowedFunctions[_functionSelector];
    }

    /// @dev Allow a function in the given state.
    /// @param stateId The id of the state
    /// @param functionSelector A function selector (bytes4[keccak256(functionSignature)])
    function allowFunction(StateMachine storage _stateMachine, bytes32 _stateId, bytes4 _functionSelector) public {
        require(_stateMachine.validState[_stateId]);
        _stateMachine.states[_stateId].allowedFunctions[_functionSelector] = true;
    }

    ///@dev add a function returning a boolean as a start condition for a state
    ///@param stateId The ID of the state to add the condition for
    ///@param condition Start condition function - returns true if a start condition (for a given state ID) is met
    function addStartCondition(StateMachine storage _stateMachine, bytes32 _stateId, function(bytes32) internal returns(bool) _condition) internal {
        require(_stateMachine.validState[_stateId]);
        _stateMachine.states[_stateId].startConditions.push(_condition);
    }

    ///@dev add a callback function for a state
    ///@param stateId The ID of the state to add a callback function for
    ///@param callback The callback function to add (if the state is valid)
    function addCallback(StateMachine storage _stateMachine, bytes32 _stateId, function() internal _callback) internal {
        require(_stateMachine.validState[_stateId]);
        _stateMachine.states[_stateId].transitionCallbacks.push(_callback);
    }

    ///@dev transitions the state machine into the state it should currently be in
    ///@dev by taking into account the current conditions and how many further transitions can occur 
    function conditionalTransitions(StateMachine storage _stateMachine) internal {

        bytes32[] storage nextStateIds = _stateMachine.states[_stateMachine.currentStateId].nextStateIds;

        while (nextStateIds.length > 0) {
            bool stateChanged = false;
            //consider each of the next states in turn
            for (uint256 j = 0; j < nextStateIds.length; j++) {
                //Get the state that you are now to consider
                bytes32 nextStateId = nextStateIds[j];
                StateMachineLib.State storage nextState = _stateMachine.states[nextStateId];
                // If one of this state's start conditions is met, go to this state and continue
                for (uint256 i = 0; i < nextState.startConditions.length; i++) {
                    if (nextState.startConditions[i](nextStateId)) {
                        goToNextState(_stateMachine,nextStateId);
                        nextStateIds = nextState.nextStateIds;
                        stateChanged = true;
                        break;
                    }
                }
                // If we have changed state, we need to break out and start again for the next state
                if (stateChanged) break;
            }
            //If we've tried all the possible following states and not changed, we're in the right state now
            if (!stateChanged) break;
        }
    }
}
