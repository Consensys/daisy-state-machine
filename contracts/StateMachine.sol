pragma solidity 0.4.19;


contract StateMachine {

    // a function that must be performed to transition into the new state
    mapping(bytes32 => function() internal[]) transitionEffects;

    // condition which must be true to transition
    mapping(bytes32 => function(bytes32) internal returns(bool)[]) startConditions;

    mapping(bytes32 => bool) transitionExists;

    // The current state id
    bytes32 public currentStateId;

    // Specifies whether the state machine has been initialised
    bool public hasBeenInitialised;

    // Maps state ids to their State structs
    mapping(bytes32 => bytes32[]) internal nextStates;

    // stores allowed functions for each state
    mapping(bytes32 => mapping(bytes4 => bool)) public allowedFunctions;

    event LogTransition(bytes32 stateId, uint256 blockNumber);

    /* This modifier performs the conditional transitions and checks that the function 
     * to be executed is allowed in the current State
     */
    modifier checkAllowed {
        conditionalTransitions();
        require(allowedFunctions[currentStateId][msg.sig]);
        _;
    }

    modifier checkInitialised {
        require(hasBeenInitialised);
        _;
    }

    /// @dev creates the whole state machine from a start state and list of transitions
    /// @dev the transitions will be parsed one by one each can only be parsed if the 
    /// @dev start state is the initial state or has been the end state of an earlier transition
    ///@param _initialState The initial state of the state machine
    ///@param _transitions a list of transitions through the state machine
    // function setupStateMachine(bytes32 _initialState, Transition[] storage _transitions) internal {
        // require(!hasBeenInitialised);
        // currentStateId = _initialState;
        // validStates[_initialState] = true;
        // for (uint256 i = 0; i < _transitions.length; i++) {
            // createTransition(_transitions[i]);
        // }
        // hasBeenInitialised = true;
    // }

    function getTransitionId(bytes32 fromId, bytes32 toId) public pure returns(bytes32) {
        return keccak256(fromId, toId);
    }

    /// @dev Creates a transition in the state machine
    /// @param _fromId The id of the state from which the transition begins.
    /// @param _toId The id of the state that will be reachable from "fromId".
    function createTransition(bytes32 fromId, bytes32 toId) internal {
        // bytes32 startState = _transition.startState;
        // require(validStates[startState]);
        // validStates[_transition.endState] = true;
        bytes32 transitionId = keccak256(fromId, toId);
        nextStates[fromId].push(toId);
        transitionExists[transitionId] = true;
    }

    function addStartCondition(bytes32 transitionId, function(bytes32) internal returns(bool) startCondition) internal {
        require(transitionExists[transitionId]);
        startConditions[transitionId].push(startCondition);
    }

    function addTransitionEffect(bytes32 transitionId, function() internal transitionEffect) internal {
        require(transitionExists[transitionId]);
        transitionEffects[transitionId].push(transitionEffect);
    }

    /// @dev Allow a function in the given state.
    /// @param stateId The id of the state
    /// @param functionSelector A function selector (bytes4[keccak256(functionSignature)])
    function allowFunction(bytes32 stateId, bytes4 functionSelector) internal {
        allowedFunctions[stateId][functionSelector] = true;
    }

    /// @dev Goes to the next state if possible (if the next state is valid)
    /// @param _nextStateId stateId of the state to transition to
    function goToNextState(bytes32 _nextStateId) public {
        // require(validStates[_nextStateId]);
        bytes32 transitionId = getTransitionId(currentStateId, _nextStateId);
        require(transitionExists[transitionId]);
        for (uint256 i = 0; i < transitionEffects[transitionId].length; i++) {
            transitionEffects[transitionId][i]();
        }
        currentStateId = _nextStateId;
        LogTransition(_nextStateId, block.number);
    }


    ///@dev transitions the state machine into the state it should currently be in
    ///@dev by taking into account the current conditions and how many further transitions can occur 
    function conditionalTransitions() internal {

        bytes32[] storage outgoing = nextStates[currentStateId];

        while (outgoing.length > 0) {
            bool stateChanged = false;
            //consider each of the next states in turn
            for (uint256 j = 0; j < outgoing.length; j++) {
                //Get the state that you are now to consider
                bytes32 nextState = outgoing[j];
                bytes32 transitionId = getTransitionId(currentStateId, nextState);
                // If this state's start condition is met, go to this state and continue
                for (uint256 i = 0; i < startConditions[transitionId].length; i++) {
                    if (startConditions[transitionId][i](nextState)) {
                        goToNextState(nextState);
                        stateChanged = true;
                        outgoing = nextStates[currentStateId];
                        break;
                    }
                }
                if (stateChanged) break;
            }
            //If we've tried all the possible following states and not changed, we're in the right state now
            if (!stateChanged) break;
        }
    }

}
