# State Machine

We implement the State Machine Pattern through the use of a library and abstract contracts. The library handles the state transitions, callbacks and the allowed functions in each stage, while the smart contracts handle conditional transitions and modifiers. 

## Library (StateMachineLib.sol)

### Structs

```
struct Stage {
    // The id of the next stage
    bytes32 nextId;

    // The identifiers for the available functions in each stage
    mapping(bytes4 => bool) allowedFunctions;
}

struct State {
    // The current stage id
    bytes32 currentStageId;

    // A callback that is called on stage transitions
    function(bytes32) internal onTransition;

    // Checks if a stage id is valid
    mapping(bytes32 => bool) validStage;

    // Maps stage ids to their Stage structs
    mapping(bytes32 => Stage) stages;
}
```

The `onTransition` callback is called everytime the state goes to another stage. It receives the id of the new stage.

## Contracts

### StateMachine.sol

The contract `StateMachine` stores a State struct and sets the `onTransition` function in the constructor. Other contracts can inherit from this contract, override the transition callbacks and set the stages and transitions between stages. 

It also contains an internal function called `startConditions` which receives the id for a stage and returns true if the start conditions for that stage are met. This function is queried when the `conditionalTransitions` function is called, and if it returns `true` for the following stage, the state goes to that stage. Also, multiple state transitions can happen in the same call of the `conditionalTransitions` function if the `startConditions` function returns `true` for multiple stages.

### TimedStateMachine.sol

The contract `TimedStateMachine` inherits from `StateMachine` and extends its functionalities by adding timestamp based automatic transitions, by overriding the `startConditions` function. This contract also provides the internal functions `setStageStartTime` and `getStageStartTime`.

## Diagram

![Dependency Diagram](/diagrams/stateMachine.png)