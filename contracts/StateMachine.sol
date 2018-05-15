pragma solidity 0.4.23;


contract StateMachine {

    // state id => (function selector => is allowed)
    mapping(bytes32 => mapping(bytes4 => bool)) allowedFunctions;

    // state id => callbacks
    mapping(bytes32 => function() internal[]) stateCallbacks;

    // from id => (to id => callbacks)
    mapping(bytes32 => mapping(bytes32 => function() internal[])) transitionCallbacks;

    // from id => (to id => start conditions)
    mapping(bytes32 => mapping(bytes32 => function(bytes32, bytes32) internal returns(bool)[])) startConditions;

    // Maps a state id to a list of state ids for which startConditions have been added
    mapping(bytes32 => bytes32[]) private existingStartConditions;

    // The current state id
    bytes32 private currentStateId;

    event Transition(bytes32 fromId, bytes32 toId);

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
        bytes32[] storage existing = existingStartConditions[currentStateId];
        for (uint256 i = 0; i < existing.length; i++) {
            bytes32 nextId = existing[i];
            for (uint256 j = 0; j < startConditions[currentStateId][nextId].length; j++) {
                if (startConditions[currentStateId][nextId][j](currentStateId, nextId)) {
                   goToState(nextId);
                   conditionalTransitions();
                }
            }
        }
    }

    function getCurrentStateId() view public returns(bytes32) {
        return currentStateId;
    }

    /// @dev Allow a function in the given state.
    /// @param _stateId The id of the state
    /// @param _functionSelector A function selector (bytes4[keccak256(functionSignature)])
    function allowFunction(bytes32 _stateId, bytes4 _functionSelector) internal {
        allowedFunctions[_stateId][_functionSelector] = true;
    }

    function goToState(bytes32 _stateId) internal {

        uint256 i;

        // Execute transition callbacks
        for (i = 0; i < transitionCallbacks[currentStateId][_stateId].length; i++) {
            transitionCallbacks[currentStateId][_stateId][i]();
        }

        // Execute state callbacks
        for(i = 0; i < stateCallbacks[_stateId].length; i++) {
            stateCallbacks[_stateId][i]();
        }

        emit Transition(currentStateId, _stateId);
        currentStateId = _stateId;
    }

    ///@dev add a function returning a boolean as a start condition for a state
    ///@param _stateId The ID of the state to add the condition for
    ///@param _condition Start condition function - returns true if a start condition (for a given state ID) is met
    function addStartCondition(bytes32 _fromId, bytes32 _toId, function(bytes32, bytes32) internal returns(bool) _condition) internal {
        if (startConditions[_fromId][_toId].length == 0) {
            existingStartConditions[_fromId].push(_toId);
        }
        startConditions[_fromId][_toId].push(_condition);
    }

    ///@dev add a callback function for a state
    ///@param _stateId The ID of the state to add a callback function for
    ///@param _callback The callback function to add
    function addCallback(bytes32 _stateId, function() internal _callback) internal {
        stateCallbacks[_stateId].push(_callback);
    }

    ///@dev add a callback function for a transition
    ///@param _fromId The ID of the state in which the transition begins
    ///@param _toId The ID of the state in which the transition ends
    ///@param _callback The callback function to add
    function addCallback(bytes32 _fromId, bytes32 _toId, function() internal _callback) internal {
        transitionCallbacks[_fromId][_toId].push(_callback);
    }

}
