import expectThrow from './helpers/expectThrow';

const StateMachineMock = artifacts.require('StateMachineMock');

contract('StateMachine', accounts => {
  let stateMachine;
  const zeroState = 0;
  const state0 = 'STATE0';
  const state1 = 'STATE1';
  const state2 = 'STATE2';
  const state3 = 'STATE3';
  let dummyFunctionSelector;


  beforeEach(async () => {
    stateMachine = await StateMachineMock.new();
    await stateMachine.setInitialStateHelper(state0);
    await stateMachine.createTransitionHelper(state0, state1);
    await stateMachine.createTransitionHelper(state0, state2);
    await stateMachine.createTransitionHelper(state1, state2);
    await stateMachine.createTransitionHelper(state1, state3);
    dummyFunctionSelector = await stateMachine.dummyFunctionSelector.call();
  });

  it('should not be possible to set initial state if there is already one', async () => {
    await expectThrow(stateMachine.setInitialStateHelper(state1));
  });

  it('should not be possible to set the intiial state as 0', async () => {
    stateMachine = await StateMachineMock.new();
    await expectThrow(stateMachine.setInitialStateHelper(zeroState));
  });

  it('should not be possible to create a transition with to or from state of 0', async () => {
    stateMachine = await StateMachineMock.new();
    await expectThrow(stateMachine.createTransitionHelper(zeroState, state1));
    await expectThrow(stateMachine.createTransitionHelper(state1, zeroState));
  });

  it('should be possible to allow a function', async () => {
    await stateMachine.allowFunctionHelper(state0, dummyFunctionSelector);
    await stateMachine.allowFunctionHelper(state1, dummyFunctionSelector);
    await stateMachine.allowFunctionHelper(state2, dummyFunctionSelector);
    await stateMachine.allowFunctionHelper(state3, dummyFunctionSelector);
  });

  it('should not be possible to call a function thats not allowed', async () => {
    await expectThrow(stateMachine.dummyFunction());
  });

  it('should be possible to call an allowed function', async () => {
    await stateMachine.allowFunctionHelper(state0, dummyFunctionSelector);
    await stateMachine.dummyFunction();
  });

  // TODO: review this.. it improves coverage but it doesn't seem necessary
  it('should not perform conditional transitions at any state', async () => {
    let currentState;
    currentState = await stateMachine.currentStateId.call();
    assert.equal(web3.toUtf8(currentState), state0);

    await stateMachine.conditionalTransitionHelper();
    currentState = await stateMachine.currentStateId.call();
    assert.equal(web3.toUtf8(currentState), state0);

    await stateMachine.goToNextStateHelper(state1);
    currentState = await stateMachine.currentStateId.call();
    assert.equal(web3.toUtf8(currentState), state1);

    await stateMachine.conditionalTransitionHelper();
    currentState = await stateMachine.currentStateId.call();
    assert.equal(web3.toUtf8(currentState), state1);

    await stateMachine.goToNextStateHelper(state2);
    currentState = await stateMachine.currentStateId.call();
    assert.equal(web3.toUtf8(currentState), state2);

    await stateMachine.conditionalTransitionHelper();

    currentState = await stateMachine.currentStateId.call();
    assert.equal(web3.toUtf8(currentState), state2);

  });

  it('should not be possible to edit the machine after it is initialised', async () => {
    await stateMachine.setDummyCondition(state0, state2);
    await stateMachine.conditionalTransitionHelper();

    let currentState = await stateMachine.currentStateId.call();
    assert.equal(web3.toUtf8(currentState), state2);
    
    await expectThrow(stateMachine.createTransitionHelper(state2, state3));
    await expectThrow(stateMachine.setDummyCondition(state0, state2));
    await expectThrow(stateMachine.setDummyTransitionEffect(state0, state2));
  });

  it('should automatically go to a state with a condition that evaluates to true', async () => {
    let currentState;
    currentState = await stateMachine.currentStateId.call();
    assert.equal(web3.toUtf8(currentState), state0);

    await stateMachine.conditionalTransitionHelper();

    currentState = await stateMachine.currentStateId.call();
    assert.equal(web3.toUtf8(currentState), state0);

    await stateMachine.setDummyCondition(state0, state1);
    await stateMachine.setDummyVariableCondition(state1, state2);

    await stateMachine.conditionalTransitionHelper();
    
    currentState = await stateMachine.currentStateId.call();
    assert.equal(web3.toUtf8(currentState), state1);

    await stateMachine.conditionalTransitionHelper();

    currentState = await stateMachine.currentStateId.call();
    assert.equal(web3.toUtf8(currentState), state1);

    await stateMachine.setCondition(true);
    await stateMachine.conditionalTransitionHelper();

    currentState = await stateMachine.currentStateId.call();
    assert.equal(web3.toUtf8(currentState), state2);
  });

  it('should be possible to set an effect for a transition', async () => {
    let transitionEffectCalled;
    transitionEffectCalled = await stateMachine.transitionEffectCalled.call();
    assert.isFalse(transitionEffectCalled);

    await stateMachine.setDummyTransitionEffect(state0, state2);
    transitionEffectCalled = await stateMachine.transitionEffectCalled.call();
    assert.isFalse(transitionEffectCalled);

    await stateMachine.goToNextStateHelper(state2);
    transitionEffectCalled = await stateMachine.transitionEffectCalled.call();
    assert.isTrue(transitionEffectCalled);
  });

  it('should not be possible to go to next state when in the last state', async () => {
    // Go to state 1
    await stateMachine.goToNextStateHelper(state1);
    // Go to state 2
    await stateMachine.goToNextStateHelper(state2);
    // Should throw because state 2 has no outgoing transitions
    await expectThrow(stateMachine.goToNextStateHelper(state3));
  });

  it('should transition to the 1st next state if both have true conditions', async () => {
    let currentState;
    currentState = await stateMachine.currentStateId.call();
    assert.equal(web3.toUtf8(currentState), state0);

    await stateMachine.setDummyCondition(state0, state1);
    await stateMachine.setDummyCondition(state0, state2);

    await stateMachine.conditionalTransitionHelper();
    
    currentState = await stateMachine.currentStateId.call();
    assert.equal(web3.toUtf8(currentState), state1);
  });


  it('should transition onwards multiple transitions if they have true conditions', async () => {
    let currentState;
    currentState = await stateMachine.currentStateId.call();
    assert.equal(web3.toUtf8(currentState), state0);

    await stateMachine.setDummyCondition(state0, state1);
    await stateMachine.setDummyCondition(state1, state3);

    await stateMachine.conditionalTransitionHelper();
    
    currentState = await stateMachine.currentStateId.call();
    assert.equal(web3.toUtf8(currentState), state3);
  });
});
