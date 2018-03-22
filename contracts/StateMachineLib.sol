pragma solidity 0.4.19;


/// @title A library for implementing a generic state machine pattern.
library StateMachineLib {

    event LogTransition(bytes32 indexed _stateId, uint256 _blockNumber);

    struct State {
        // The id of the next state
        bytes32[] nextStateIds;

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

    /// @dev Creates a transition from 'fromId' to 'toId'. If fromId already had a nextStateId, it deletes the now unreachable state.
    /// @param fromId The id of the state from which the transition begins.
    /// @param toId The id of the state that will be reachable from "fromId".
    function createTransition(StateMachine storage _stateMachine, bytes32 _fromId, bytes32 _toId) public {
        require(_stateMachine.validState[_fromId]);

        State storage from = _stateMachine.states[_fromId];
        _stateMachine.validState[_toId] = true;
        from.nextStateIds.push(_toId);
    }

    /// @dev Creates the given states.
    /// @param stateIds Array of state ids.
    function setStates(StateMachine storage _stateMachine, bytes32[] stateIds) public {
        require(stateIds.length > 0);

        setInitialState(_stateMachine, stateIds[0]);

        for (uint256 i = 1; i < stateIds.length; i++) {
            createTransition(_stateMachine, stateIds[i - 1], stateIds[i]);
        }
    }

    /// @dev Goes to the next state if posible (if the next state is valid)
    function goToNextState(StateMachine storage _stateMachine, bytes32 _nextStateId) internal {
        State storage currentState = _stateMachine.states[_stateMachine.currentStateId];
        require(_stateMachine.validState[_nextStateId]);

        for (uint256 i = 0; i < currentState.nextStateIds.length; i++) {
            if (currentState.nextStateIds[i] == _nextStateId) {
                _stateMachine.currentStateId = _nextStateId;
                State storage nextState = _stateMachine.states[_nextStateId];
                for (uint256 j = 0; j < nextState.transitionCallbacks.length; j++) {
                    nextState.transitionCallbacks[j]();
                }
                
                emit LogTransition(_nextStateId, block.number);
                break;
            }
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

        bytes32[] nextStateIds = _stateMachine.states[_stateMachine.currentStateId].nextStateIds;

        while (_stateMachine.validState[nextStateId]) {
            StateMachineLib.State storage nextState = _stateMachine.states[nextStateId];
            // If one of the next state's conditions is met, go to this state and continue
            bool stateChanged = false;
            for (uint256 i = 0; i < nextState.startConditions.length; i++) {
                if (nextState.startConditions[i](nextStateId)) {
                    goToNextState(_stateMachine);
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
