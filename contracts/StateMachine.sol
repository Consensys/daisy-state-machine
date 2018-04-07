pragma solidity 0.4.19;


contract StateMachine {

    // a function that must be performed to transition into the new state
    mapping(bytes32 => function() internal[]) transitionEffects;

    // condition which must be true to transition
    mapping(bytes32 => function(bytes32) internal returns(bool)[]) startConditions;

    mapping(bytes32 => bool) transitionExists;

    // The current state id
    bytes32 public currentStateId;

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

    
    function getTransitionId(bytes32 _fromId, bytes32 _toId) public pure returns(bytes32) {
        return keccak256(_fromId, _toId);
    }

    /// @dev Creates a transition in the state machine
    /// @param _fromId The id of the state from which the transition begins.
    /// @param _toId The id of the state that will be reachable from "fromId".
    function createTransition(bytes32 _fromId, bytes32 _toId) internal {
        bytes32 transitionId = getTransitionId(_fromId, _toId);
        nextStates[_fromId].push(_toId);
        transitionExists[transitionId] = true;
    }

    function addStartCondition(bytes32 _fromId, bytes32 _toId, function(bytes32) internal returns(bool) _startCondition) internal {
        bytes32 transitionId = getTransitionId(_fromId, _toId);
        require(transitionExists[transitionId]);
        startConditions[transitionId].push(_startCondition);
    }

    function addTransitionEffect(bytes32 _fromId, bytes32 _toId, function() internal transitionEffect) internal {
        bytes32 transitionId = getTransitionId(_fromId, _toId);
        require(transitionExists[transitionId]);
        transitionEffects[transitionId].push(transitionEffect);
    }

    /// @dev Allow a function in the given state.
    /// @param stateId The id of the state
    /// @param functionSelector A function selector (bytes4[keccak256(functionSignature)])
    function allowFunction(bytes32 _stateId, bytes4 _functionSelector) internal {
        allowedFunctions[_stateId][_functionSelector] = true;
    }

    /// @dev Goes to the next state if possible (if the next state is valid)
    /// @param _nextStateId stateId of the state to transition to
    function goToNextState(bytes32 _nextStateId) internal {
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
