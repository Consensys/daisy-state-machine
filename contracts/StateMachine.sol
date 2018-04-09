pragma solidity 0.4.19;


contract StateMachine {

    // Maps a stateId to the stateId of the next state
    mapping(bytes32 => bytes32) public nextStateId;

    // For each stateId, specify which functions are available
    mapping(bytes32 => mapping(bytes4 => bool)) public allowedFunctions;

    // Maps a stateId to an array of callbacks
    mapping(bytes32 => function() internal[]) private transitionCallbacks;

    // Maps a stateId to an array of conditions
    mapping(bytes32 => function(bytes32) internal returns(bool)[]) private startConditions;

    // The current state id
    bytes32 public currentStateId;

    event LogTransition(bytes32 stateId, uint256 blockNumber);

    /* This modifier performs the conditional transitions and checks that the function 
     * to be executed is allowed in the current State
     */
    modifier checkAllowed {
        conditionalTransitions();
        require(allowedFunctions[currentStateId][msg.sig]);
        _;
    }

    ///@dev transitions the state machine into the state it should currently be in
    ///@dev by taking into account the current conditions and how many further transitions can occur 
    function conditionalTransitions() public {

        bytes32 next = nextStateId[currentStateId];

        while (next != 0) {
            // If one of the next state's conditions is met, go to this state and continue
            bool stateChanged = false;
            for (uint256 i = 0; i < startConditions[next].length; i++) {
                if (startConditions[next][i](next)) {
                    goToNextState();
                    next = nextStateId[next];
                    stateChanged = true;
                    break;
                }
            }
            // If none of the next state's conditions are met, then we are in the right current state
            if (!stateChanged) break;
        }
    }

    /// @dev Setup the state machine with the given states.
    /// @param stateIds Array of state ids.
    function setStates(bytes32[] stateIds) internal {
        require(stateIds.length > 0);
        require(currentStateId == 0);

        require(stateIds[0] != 0);

        currentStateId = stateIds[0];

        for (uint256 i = 1; i < stateIds.length; i++) {
            require(stateIds[i] != 0);
            nextStateId[stateIds[i - 1]] = stateIds[i];
        }
    }

    /// @dev Allow a function in the given state.
    /// @param stateId The id of the state
    /// @param functionSelector A function selector (bytes4[keccak256(functionSignature)])
    function allowFunction(bytes32 stateId, bytes4 functionSelector) internal {
        allowedFunctions[stateId][functionSelector] = true;
    }

    /// @dev Goes to the next state if posible (if the next state is valid)
    function goToNextState() internal {
        bytes32 next = nextStateId[currentStateId];
        require(next != 0);

        currentStateId = next;

        for (uint256 i = 0; i < transitionCallbacks[next].length; i++) {
            transitionCallbacks[next][i]();
        }

        LogTransition(next, block.number);
    }

    ///@dev add a function returning a boolean as a start condition for a state
    ///@param stateId The ID of the state to add the condition for
    ///@param condition Start condition function - returns true if a start condition (for a given state ID) is met
    function addStartCondition(bytes32 stateId, function(bytes32) internal returns(bool) condition) internal {
        startConditions[stateId].push(condition);
    }

    ///@dev add a callback function for a state
    ///@param stateId The ID of the state to add a callback function for
    ///@param callback The callback function to add (if the state is valid)
    function addCallback(bytes32 stateId, function() internal callback) internal {
        transitionCallbacks[stateId].push(callback);
    }
}
