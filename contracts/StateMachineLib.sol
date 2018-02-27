pragma solidity 0.4.19;


/// @title A library for implementing a generic state machine pattern.
library StateMachineLib {

    struct Stage {
        // The id of the next stage
        bytes32 nextId;

        // The identifiers for the available functions in each stage
        mapping(bytes4 => bool) allowedFunctions;
    }

    struct State {
        // The current stage id
        bytes32 currentStageId;

        // A callback that is called when entering this stage
        function(bytes32) internal onTransition;

        // Checks if a stage id is valid
        mapping(bytes32 => bool) validStage;

        // Maps stage ids to their Stage structs
        mapping(bytes32 => Stage) stages;
    }

    /// @dev Creates and sets the initial stage. It has to be called before creating any transitions.
    /// @param stageId The id of the (new) stage to set as initial stage.
    function setInitialStage(State storage self, bytes32 stageId) internal {
        require(self.currentStageId == 0);
        self.validStage[stageId] = true;
        self.currentStageId = stageId;
    }

    /// @dev Creates a transition from 'fromId' to 'toId'. If fromId already had a nextId, it deletes the now unreachable stage.
    /// @param fromId The id of the stage from which the transition begins.
    /// @param toId The id of the stage that will be reachable from "fromId".
    function createTransition(State storage self, bytes32 fromId, bytes32 toId) internal {
        require(self.validStage[fromId]);

        Stage storage from = self.stages[fromId];

        // Invalidate the stage that won't be reachable any more
        if (from.nextId != 0) {
            self.validStage[from.nextId] = false;
            delete self.stages[from.nextId];
        }

        from.nextId = toId;
        self.validStage[toId] = true;
    }

    /// @dev Creates the given stages.
    /// @param stageIds Array of stage ids.
    function setStages(State storage self, bytes32[] stageIds) internal {
        require(stageIds.length > 0);

        setInitialStage(self, stageIds[0]);

        for (uint256 i = 1; i < stageIds.length; i++) {
            createTransition(self, stageIds[i - 1], stageIds[i]);
        }
    }

    /// @dev Goes to the next stage if posible (if the next stage is valid)
    function goToNextStage(State storage self) internal {
        Stage storage current = self.stages[self.currentStageId];

        require(self.validStage[current.nextId]);

        self.currentStageId = current.nextId;

        self.onTransition(current.nextId);
    }

    /// @dev Checks if the a function is allowed in the current stage.
    /// @param selector A function selector (bytes4[keccak256(functionSignature)])
    /// @return true If the function is allowed in the current stage
    function checkAllowedFunction(State storage self, bytes4 selector) internal constant returns(bool) {
        return self.stages[self.currentStageId].allowedFunctions[selector];
    }

    /// @dev Allow a function in the given stage.
    /// @param stageId The id of the stage
    /// @param selector A function selector (bytes4[keccak256(functionSignature)])
    function allowFunction(State storage self, bytes32 stageId, bytes4 selector) internal {
        require(self.validStage[stageId]);
        self.stages[stageId].allowedFunctions[selector] = true;
    }


}
