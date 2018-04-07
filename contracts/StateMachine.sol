pragma solidity 0.4.19;


contract StateMachine {

    // a function that must be performed when transitioning into the new state
    mapping(bytes32 => function() internal[]) transitionEffects;

    // condition which must be true to perform a transition
    mapping(bytes32 => function(bytes32) internal returns(bool)[]) startConditions;

    // mapping transition id to bool
    mapping(bytes32 => bool) transitionExists;

    // The current state id
    bytes32 public currentStateId;

    // Maps state ids to all states reachable by 1 transition
    mapping(bytes32 => bytes32[]) internal nextStates;

    // stores true/false for allowed functions in each state
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

    function setInitialState(bytes32 _initialState) internal {
        require (currentStateId == 0);
        require (_initialState != 0);
        currentStateId = _initialState;
    }

    /// @dev returns the id of the transition between 2 states.
    /// @param _fromStateId The id of the start state of the transition.
    /// @param _toStateId The id of the end state of the transition.
    function getTransitionId(bytes32 _fromStateId, bytes32 _toStateId) public pure returns(bytes32) {
        require(_fromStateId != 0);
        require(_toStateId != 0);
        return keccak256(_fromStateId, _toStateId);
    }

    /// @dev Creates a transition in the state machine
    /// @param _fromStateId The id of the start state of the transition.
    /// @param _toStateId The id of the end state of the transition.
    function createTransition(bytes32 _fromStateId, bytes32 _toStateId) internal {
        bytes32 transitionId = getTransitionId(_fromStateId, _toStateId);
        nextStates[_fromStateId].push(_toStateId);
        transitionExists[transitionId] = true;
    }

    /// @dev adds a condition that must be true for a transition to occur.
    /// @param _fromStateId The id of the start state of the transition.
    /// @param _toStateId The id of the end state of the transition.
    /// @param _startCondition The condition itself.
    function addStartCondition(bytes32 _fromStateId, bytes32 _toStateId, function(bytes32) internal returns(bool) _startCondition) internal {
        bytes32 transitionId = getTransitionId(_fromStateId, _toStateId);
        require(transitionExists[transitionId]);
        startConditions[transitionId].push(_startCondition);
    }

    /// @dev adds an effect that is performed when a transition occurs
    /// @param _fromStateId The id of the start state of the transition.
    /// @param _toStateId The id of the end state of the transition.
    /// @param _transitionEffect The effect itself.
    function addTransitionEffect(bytes32 _fromStateId, bytes32 _toStateId, function() internal _transitionEffect) internal {
        bytes32 transitionId = getTransitionId(_fromStateId, _toStateId);
        require(transitionExists[transitionId]);
        transitionEffects[transitionId].push(_transitionEffect);
    }

    /// @dev Allow a function in the given state.
    /// @param _stateId The id of the state
    /// @param _functionSelector A function selector (bytes4[keccak256(functionSignature)])
    function allowFunction(bytes32 _stateId, bytes4 _functionSelector) internal {
        allowedFunctions[_stateId][_functionSelector] = true;
    }

    /// @dev Goes to the next state if possible (if the next state is valid and reachable by a transition from the current state)
    /// @param _nextStateId stateId of the state to transition to
    function goToNextState(bytes32 _nextStateId) internal {
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
