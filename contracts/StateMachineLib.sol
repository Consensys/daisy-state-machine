pragma solidity 0.4.19;


/// @title A library for implementing a generic state machine pattern.
library StateMachineLib {

    event LogTransition(bytes32 indexed _stateId, uint256 _blockNumber);

    struct Transition {

        // Ids of the transitions start and end states
        bytes32 startState;
        bytes32 endState;

        //a function that must be performed to transition into the new state
        function() internal transitionEffect;

        //condition which must be true to transition
        function(bytes32) internal returns(bool) startCondition;
    }

    struct StateMachine {
        // The current state id
        bytes32 currentStateId;

        // Checks if a state id is valid
        mapping(bytes32 => bool) validStates;

        // Maps state ids to their State structs
        mapping(bytes32 => Transition[]) outgoingTransitions;

        // stores allowed functions for each state
        mapping(bytes32 => mapping(bytes4 => bool)) allowedFunctions;

    }

    /// @dev Creates and sets the initial state. It has to be called before creating any transitions.
    /// @param _stateId The id of the (new) state to set as initial state.
    function setInitialState(StateMachine storage _stateMachine, bytes32 _stateId) public {
        require(_stateMachine.currentStateId == 0);
        _stateMachine.validStates[_stateId] = true;
        _stateMachine.currentStateId = _stateId;
    }

    /// @dev Creates a transition in the state machine
    /// @param _fromId The id of the state from which the transition begins.
    /// @param _toId The id of the state that will be reachable from "fromId".
    function createTransition(StateMachine storage _stateMachine, Transition storage _transition) public {
        bytes32 startState = _transition.startState;
        require(_stateMachine.validStates[startState]);
        _stateMachine.validStates[_transition.endState] = true;
        _stateMachine.outgoingTransitions[startState].push(_transition);
    }

    /// @dev creates the whole state machine from a start state and list of transitions
    /// @dev the transitions will be parsed one by one each can only be parsed if the 
    /// @dev start state is the initial state or has been the end state of an earlier transition
    ///@param _initialState The initial state of the state machine
    ///@param _transitions a list of transitions through the state machine
    function setupStateMachine(StateMachine storage _stateMachine, bytes32 _initialState, Transition[] storage _transitions) public {
        _stateMachine.setInitialState(_initialState);
        for (uint256 i = 0; i < _transitions.length; i++) {
            _stateMachine.createTransition(_transitions[i]);
        }
    }

    
    /// @dev Goes to the next state if possible (if the next state is valid)
    /// @param _nextStateId stateId of the state to transition to
    function goToNextState(StateMachine storage _stateMachine, bytes32 _nextStateId) public {
        require(_stateMachine.validState[_nextStateId]);
        Transition[] storage outgoingTransitions = _stateMachine.outgoingTransitions[_stateMachine.currentStateId];

        for (uint256 i = 0; i < outgoingTransitions.length; i++) {
            if (outgoingTransitions[i].endState == _nextStateId) {
                _stateMachine.performTransition(outgoingTransitions[i]);
            }
        }
             
        LogTransition(_nextStateId, block.number);
    }


    function performTransition(StateMachine storage _stateMachine, Transition transition) public {
        require(_stateMachine.currentStateId == transition.startState);
        //does it matter which way round the next 2 lines are???
        transition.transitionEffect();
        _stateMachine.currentStateId = transition.endState;
    }

    /// @dev Checks if a function is allowed in the current state.
    /// @param _functionSelector A function selector (bytes4[keccak256(functionSignature)])
    /// @return true If the function is allowed in the current state
    function checkAllowedFunction(StateMachine storage _stateMachine, bytes4 _functionSelector) public constant returns(bool) {
        require (_stateMachine.validState[_stateMachine.currentStateId]);
        return _stateMachine.allowedFunctions[_stateMachine.currentStateId][_functionSelector];
    }

    /// @dev Allow a function in the given state.
    /// @param _stateId The id of the state
    /// @param _functionSelector A function selector (bytes4[keccak256(functionSignature)])
    function allowFunction(StateMachine storage _stateMachine, bytes32 _stateId, bytes4 _functionSelector) public {
        require(_stateMachine.validState[_stateId]);
        _stateMachine.allowedFunctions[_stateId][_functionSelector] = true;
    }

    ///@dev transitions the state machine into the state it should currently be in
    ///@dev by taking into account the current conditions and how many further transitions can occur 
    function conditionalTransitions(StateMachine storage _stateMachine) internal {

        Transition[] storage outgoingTransitions = _stateMachine.outgoingTransitions[_stateMachine.currentStateId];

        while (outgoingTransitions.length > 0) {
            bool stateChanged = false;
            //consider each of the next states in turn
            for (uint256 j = 0; j < outgoingTransitions.length; j++) {
                //Get the state that you are now to consider
                Transition storage transition = outgoingTransitions[j];
                // If this state's start condition is met, go to this state and continue
                if (transition.startCondition(transition.endState)) {
                    _stateMachine.performTransition(transition);
                    outgoingTransitions = _stateMachine.outgoingTransitions[transition.endState];
                    stateChanged = true;
                }
                // If we have changed state, we need to break out and start again for the next state
                if (stateChanged) break;
            }
            //If we've tried all the possible following states and not changed, we're in the right state now
            if (!stateChanged) break;
        }
    }

}
