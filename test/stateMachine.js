import expectThrow from './helpers/expectThrow';

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
    stateMachine = await StateMachineMock.new();
    await stateMachine.setStatesHelper([state0, state1, state2, state3]);
    dummyFunctionSelector = await stateMachine.dummyFunctionSelector.call();
  });

  it('should not be possible to set states if there is already one', async () => {
    await expectThrow(stateMachine.setStatesHelper([invalidState]));
  });

  it('should not be possible to use an empty array for setting the states', async () => {
    stateMachine = await StateMachineMock.new();
    await expectThrow(stateMachine.setStatesHelper([]));
  });

  it('should be possible to allow a function', async () => {
    await stateMachine.allowFunctionHelper(state0, dummyFunctionSelector);
    await stateMachine.allowFunctionHelper(state1, dummyFunctionSelector);
    await stateMachine.allowFunctionHelper(state2, dummyFunctionSelector);
    await stateMachine.allowFunctionHelper(state3, dummyFunctionSelector);
  });

  it('should not be possible to call an unallowed function', async () => {
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

    await stateMachine.conditionalTransitions();

    currentState = await stateMachine.currentStateId.call();
    assert.equal(web3.toUtf8(currentState), state0);

    await stateMachine.goToNextStateHelper();
    currentState = await stateMachine.currentStateId.call();
    assert.equal(web3.toUtf8(currentState), state1);

    await stateMachine.conditionalTransitions();

    currentState = await stateMachine.currentStateId.call();
    assert.equal(web3.toUtf8(currentState), state1);

    await stateMachine.goToNextStateHelper();
    currentState = await stateMachine.currentStateId.call();
    assert.equal(web3.toUtf8(currentState), state2);

    await stateMachine.conditionalTransitions();

    currentState = await stateMachine.currentStateId.call();
    assert.equal(web3.toUtf8(currentState), state2);

    await stateMachine.goToNextStateHelper();
    currentState = await stateMachine.currentStateId.call();
    assert.equal(web3.toUtf8(currentState), state3);

    await stateMachine.conditionalTransitions();

    currentState = await stateMachine.currentStateId.call();
    assert.equal(web3.toUtf8(currentState), state3);
  });

  it('should automatically go to a state with a condition that evaluates to true', async () => {
    let currentState;
    currentState = await stateMachine.currentStateId.call();
    assert.equal(web3.toUtf8(currentState), state0);

    await stateMachine.conditionalTransitions();

    currentState = await stateMachine.currentStateId.call();
    assert.equal(web3.toUtf8(currentState), state0);

    await stateMachine.setDummyCondition(state1);
    //THIS LINE THROWS THE ERROR
    await stateMachine.conditionalTransitions();
    
    currentState = await stateMachine.currentStateId.call();
    assert.equal(web3.toUtf8(currentState), state1);

    await stateMachine.setDummyVariableCondition(state2);
    await stateMachine.conditionalTransitions();

    currentState = await stateMachine.currentStateId.call();
    assert.equal(web3.toUtf8(currentState), state1);

    await stateMachine.setCondition(true);
    await stateMachine.conditionalTransitions();

    currentState = await stateMachine.currentStateId.call();
    assert.equal(web3.toUtf8(currentState), state2);
  });

  it('should be possible to set a callback for a state', async () => {
    let callbackCalled;
    callbackCalled = await stateMachine.callbackCalled.call();
    assert.isFalse(callbackCalled);

    await stateMachine.setDummyCallback(state1);
    callbackCalled = await stateMachine.callbackCalled.call();
    assert.isFalse(callbackCalled);
    //THIS LINE THROWS THE ERROR
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
