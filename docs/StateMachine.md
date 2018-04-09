# State Machine

We implement the State Machine Pattern through the use of base contracts that are meant to be inherited from. The contracts handle state transitions, callbacks and the allowed functions in each state. 

## Contracts

### StateMachine.sol

The contract `StateMachine` stores all the state data. Each state is represented by a unique `bytes32 stateId` defined by the user. Each state is mapped to the next state id, the allowed functions in that state, an array of transition callbacks and an array of start conditions.

The `checkAllowed` modifier performs `conditionalTransitions()` and checks that the function is allowed in the current state.

### TimedStateMachine.sol

The contract `TimedStateMachine` inherits from `StateMachine` and extends its functionalities by adding timestamp based automatic transitions, by adding a `hasStartTimePassed` condition to the startConditions array for each state. This contract also provides the internal function `setStageStartTime` and public function `getStageStartTime`.

## Diagram

![Dependency Diagram](/diagrams/stateMachine.png)
