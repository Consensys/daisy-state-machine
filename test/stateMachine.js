import expectThrow from './helpers/expectThrow';

const StateMachineLib = artifacts.require('StateMachineLib');
const StateMachineMock = artifacts.require('StateMachineMock');

contract('StateMachine', accounts => {
  let stateMachine;
  const invalidState = 'invalid';
  const state0 = 'STATE0';
  const state1 = 'STATE1';
  const state2 = 'STATE2';
  const state3 = 'STATE3';
  let dummyFunctionSelector;


  beforeEach(async () => {
    const stateMachineLib = await StateMachineLib.new();
    StateMachineMock.link('StateMachineLib', stateMachineLib.address);
    stateMachine = await StateMachineMock.new();
    await stateMachine.setStatesHelper([state0, state1, state2, state3]);
    dummyFunctionSelector = await stateMachine.dummyFunctionSelector.call();
  });

  it('should not be possible to set an initial state if there is already one', async () => {
    await expectThrow(stateMachine.setStatesHelper([invalidState]));
  });

  it('should not be possible to use an empty array for setting the states', async () => {
    stateMachine = await StateMachineMock.new();
    await expectThrow(stateMachine.setStatesHelper([]));
  });

  it('should not be possible to create a transition from an invalid state', async () => {
    await expectThrow(stateMachine.createTransition(invalidState, state0));
  });

  it('should not be possible to allow a function for an invalid state', async () => {
    await expectThrow(stateMachine.allowFunction(invalidState, dummyFunctionSelector));
  });

  it('should be possible to allow a function for a valid state', async () => {
    await stateMachine.allowFunction(state0, dummyFunctionSelector);
    await stateMachine.allowFunction(state1, dummyFunctionSelector);
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

    await stateMachine.goToNextStateHelper();
    currentState = await stateMachine.getCurrentStateId.call();
    assert.equal(web3.toUtf8(currentState), state1);

    await stateMachine.conditionalTransitions();

    currentState = await stateMachine.getCurrentStateId.call();
    assert.equal(web3.toUtf8(currentState), state1);

    await stateMachine.goToNextStateHelper();
    currentState = await stateMachine.getCurrentStateId.call();
    assert.equal(web3.toUtf8(currentState), state2);

    await stateMachine.conditionalTransitions();

    currentState = await stateMachine.getCurrentStateId.call();
    assert.equal(web3.toUtf8(currentState), state2);

    await stateMachine.goToNextStateHelper();
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

    await stateMachine.setDummyCondition(state1);
    await stateMachine.conditionalTransitions();

    currentState = await stateMachine.getCurrentStateId.call();
    assert.equal(web3.toUtf8(currentState), state1);

    await stateMachine.setDummyVariableCondition(state2);
    await stateMachine.conditionalTransitions();

    currentState = await stateMachine.getCurrentStateId.call();
    assert.equal(web3.toUtf8(currentState), state1);

    await stateMachine.setCondition(true);
    await stateMachine.conditionalTransitions();

    currentState = await stateMachine.getCurrentStateId.call();
    assert.equal(web3.toUtf8(currentState), state2);
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

    await stateMachine.goToNextStateHelper();
    callbackCalled = await stateMachine.callbackCalled.call();
    assert.isTrue(callbackCalled);
  });

  it('should not be possible to go to next state when in the last state', async () => {
    // Go to state 1
    await stateMachine.goToNextStateHelper();
    // Go to state 2
    await stateMachine.goToNextStateHelper();
    // Go to state 3
    await stateMachine.goToNextStateHelper();
    // Should throw because state 3 is the last state
    await expectThrow(stateMachine.goToNextStateHelper());
  });
});
