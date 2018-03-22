import expectThrow from './helpers/expectThrow';

const StateMachineLib = artifacts.require('StateMachineLib');
const StateMachineMock = artifacts.require('StateMachineMock');

contract('StateMachine', accounts => {
  let stateMachine;
  const invalidState = 'invalid';
  const state0 = 'STATE0';
  const state1a = 'STATE1A';
  const state1b = 'STATE1B';
  const state2 = 'STATE2';
  const state3 = 'STATE3';
  let dummyFunctionSelector;


  beforeEach(async () => {
    const stateMachineLib = await StateMachineLib.new();
    StateMachineMock.link('StateMachineLib', stateMachineLib.address);
    stateMachine = await StateMachineMock.new();
    await stateMachine.setInitialStateHelper(state0)
    await stateMachine.createTransitionArrayHelper(state0, [state1a, state1b]);
    await stateMachine.createTransitionHelper(state1a, state2);
    await stateMachine.createTransitionHelper(state1b, state2);
    await stateMachine.createTransitionHelper(state2, state3);
    dummyFunctionSelector = await stateMachine.dummyFunctionSelector.call();
  });

  it('should not be possible to set an initial state if there is already one', async () => {
    await expectThrow(stateMachine.setInitialStateHelper(invalidState));
  });

  it('should not be possible to create a transition from an invalid state', async () => {
    await expectThrow(stateMachine.createTransitionHelper(invalidState, state0));
  });

  it('should not be possible to create an array of transitions from an invalid state', async () => {
    await expectThrow(stateMachine.createTransitionArrayHelper(invalidState, [state0,state1a]));
  });

  it('should not be possible to create an array of transitions for an empty array', async () => {
    await expectThrow(stateMachine.createTransitionArrayHelper(state1a, []));
  });

  it('should not be possible to allow a function for an invalid state', async () => {
    await expectThrow(stateMachine.allowFunction(invalidState, dummyFunctionSelector));
  });

  it('should be possible to allow a function for a valid state', async () => {
    await stateMachine.allowFunction(state0, dummyFunctionSelector);
    await stateMachine.allowFunction(state1a, dummyFunctionSelector);
    await stateMachine.allowFunction(state1b, dummyFunctionSelector);
    await stateMachine.allowFunction(state2, dummyFunctionSelector);
    await stateMachine.allowFunction(state3, dummyFunctionSelector);
  });

  it('should not be possible to call an unallowed function', async () => {
    await expectThrow(stateMachine.dummyFunction());
  });

  it('should be possible to call an allowed function', async () => {
    await stateMachine.allowFunction(state0, dummyFunctionSelector);
    await stateMachine.dummyFunction();
  });

  // TODO: review this.. it improves coverage but it doesn't seem necessary
  it('should not perform conditional transitions at any state', async () => {
    let currentState;
    currentState = await stateMachine.getCurrentStateId.call();
    assert.equal(web3.toUtf8(currentState), state0);

    await stateMachine.conditionalTransitions();

    currentState = await stateMachine.getCurrentStateId.call();
    assert.equal(web3.toUtf8(currentState), state0);

    await stateMachine.goToNextStateHelper(state1a);
    currentState = await stateMachine.getCurrentStateId.call();
    assert.equal(web3.toUtf8(currentState), state1a);

    await stateMachine.conditionalTransitions();

    currentState = await stateMachine.getCurrentStateId.call();
    assert.equal(web3.toUtf8(currentState), state1a);

    await stateMachine.goToNextStateHelper(state2);
    currentState = await stateMachine.getCurrentStateId.call();
    assert.equal(web3.toUtf8(currentState), state2);

    await stateMachine.conditionalTransitions();

    currentState = await stateMachine.getCurrentStateId.call();
    assert.equal(web3.toUtf8(currentState), state2);

    await stateMachine.goToNextStateHelper(state3);
    currentState = await stateMachine.getCurrentStateId.call();
    assert.equal(web3.toUtf8(currentState), state3);

    await stateMachine.conditionalTransitions();

    currentState = await stateMachine.getCurrentStateId.call();
    assert.equal(web3.toUtf8(currentState), state3);
  });

  it('should not be possible to set a start condition for an invalid state', async () => {
    await expectThrow(stateMachine.setDummyCondition(invalidState));
    await expectThrow(stateMachine.setDummyVariableCondition(invalidState));
  });

  it('should automatically go to a state with a condition that evaluates to true', async () => {
    let currentState;
    currentState = await stateMachine.getCurrentStateId.call();
    assert.equal(web3.toUtf8(currentState), state0);

    await stateMachine.conditionalTransitions();

    currentState = await stateMachine.getCurrentStateId.call();
    assert.equal(web3.toUtf8(currentState), state0);

    await stateMachine.setDummyCondition(state1a);
    await stateMachine.conditionalTransitions();
    
    currentState = await stateMachine.getCurrentStateId.call();
    assert.equal(web3.toUtf8(currentState), state1a);

    //variable condition is currently false so no transition happens
    await stateMachine.setDummyVariableCondition(state2);
    await stateMachine.conditionalTransitions();

    currentState = await stateMachine.getCurrentStateId.call();
    assert.equal(web3.toUtf8(currentState), state1a);

    //variable condition is now true so transition happens
    await stateMachine.setCondition(true);
    await stateMachine.conditionalTransitions();

    currentState = await stateMachine.getCurrentStateId.call();
    assert.equal(web3.toUtf8(currentState), state2);
  });

  it('should transition to a valid next state even if the first next state is false', async () => {
    let currentState;
    currentState = await stateMachine.getCurrentStateId.call();
    assert.equal(web3.toUtf8(currentState), state0);

    await stateMachine.setDummyCondition(state1b);
    await stateMachine.conditionalTransitions();
    
    currentState = await stateMachine.getCurrentStateId.call();
    assert.equal(web3.toUtf8(currentState), state1b);
  });

  it('should transition to the first of 2 next states if both are true', async () => {
    let currentState;
    currentState = await stateMachine.getCurrentStateId.call();
    assert.equal(web3.toUtf8(currentState), state0);

    await stateMachine.setDummyCondition(state1a);
    await stateMachine.setDummyCondition(state1b);
    await stateMachine.conditionalTransitions();
    
    currentState = await stateMachine.getCurrentStateId.call();
    assert.equal(web3.toUtf8(currentState), state1a);
  });

  it('should not be possible to set a callback for an invalid state', async () => {
    await expectThrow(stateMachine.setDummyCallback(invalidState));
  });

  it('should be possible to set a callback for a valid state', async () => {
    let callbackCalled;
    callbackCalled = await stateMachine.callbackCalled.call();
    assert.isFalse(callbackCalled);

    await stateMachine.setDummyCallback(state1);
    callbackCalled = await stateMachine.callbackCalled.call();
    assert.isFalse(callbackCalled);

    await stateMachine.goToNextStateHelper(state1a);
    callbackCalled = await stateMachine.callbackCalled.call();
    assert.isTrue(callbackCalled);
  });

  it('should be possible to go to next state when it does follow the current state', async () => {
    await stateMachine.goToNextStateHelper(state1a);
    await stateMachine.goToNextStateHelper(state2);
    await stateMachine.goToNextStateHelper(state3);
  });

  it('should be possible to go to next state when it isn\'t the first next state', async () => {
    await stateMachine.goToNextStateHelper(state1b);
  });
  it('should not be possible to go to next state when it does not follow the current state', async () => {
    await expectThrow(stateMachine.goToNextStateHelper(state2));
  });
});
