import expectThrow from './helpers/expectThrow';

const StateMachineMock = artifacts.require('StateMachineMock');

contract('StateMachine', accounts => {
  let stateMachine;
  const invalidState = 'invalid';
  const zeroState = 0;
  const stateA = 'STATEA';
  const stateB = 'STATEB';
  const stateC = 'STATEC';
  const stateD = 'STATED';

  let fallbackState;

  let dummyFunctionSelector;


  beforeEach(async () => {
    stateMachine = await StateMachineMock.new();
    fallbackState = await stateMachine.FALLBACK.call();
    dummyFunctionSelector = await stateMachine.dummyFunctionSelector.call();
    stateMachine.setInitialStateHelper(stateA);
  });

  it('should not be possible to set the initial state more than once', async () => {
    await expectThrow(stateMachine.setInitialStateHelper(stateB));
  });

  it('should be possible to allow a function', async () => {
    await stateMachine.allowFunctionHelper(stateA, dummyFunctionSelector);
    await stateMachine.allowFunctionHelper(stateB, dummyFunctionSelector);
    await stateMachine.allowFunctionHelper(stateC, dummyFunctionSelector);
    await stateMachine.allowFunctionHelper(stateD, dummyFunctionSelector);
  });

  it('should not be possible to call an unallowed function', async () => {
    await expectThrow(stateMachine.dummyFunction());
  });

  it('should be possible to call an allowed function', async () => {
    await stateMachine.allowFunctionHelper(stateA, dummyFunctionSelector);
    await stateMachine.dummyFunction();
  });

  // TODO: review this.. it improves coverage but it doesn't seem necessary
  // it('should not perform conditional transitions at any state', async () => {
    // let currentState;
    // currentState = await stateMachine.getCurrentStateId.call();
    // assert.equal(web3.toUtf8(currentState), stateA);

    // await stateMachine.conditionalTransitions();

    // currentState = await stateMachine.getCurrentStateId.call();
    // assert.equal(web3.toUtf8(currentState), stateB);

    // await stateMachine.goToNextStateHelper();
    // currentState = await stateMachine.getCurrentStateId.call();
    // assert.equal(web3.toUtf8(currentState), stateC);

    // await stateMachine.conditionalTransitions();

    // currentState = await stateMachine.getCurrentStateId.call();
    // assert.equal(web3.toUtf8(currentState), state1);

    // await stateMachine.goToNextStateHelper();
    // currentState = await stateMachine.getCurrentStateId.call();
    // assert.equal(web3.toUtf8(currentState), state2);

    // await stateMachine.conditionalTransitions();

    // currentState = await stateMachine.getCurrentStateId.call();
    // assert.equal(web3.toUtf8(currentState), state2);

    // await stateMachine.goToNextStateHelper();
    // currentState = await stateMachine.getCurrentStateId.call();
    // assert.equal(web3.toUtf8(currentState), state3);

    // await stateMachine.conditionalTransitions();

    // currentState = await stateMachine.getCurrentStateId.call();
    // assert.equal(web3.toUtf8(currentState), state3);
  // });

  it('should automatically perform a transition if there exists a condition that evaluates to true for that transition', async () => {
    let currentState;
    currentState = await stateMachine.getCurrentStateId.call();
    assert.equal(web3.toUtf8(currentState), stateA);

    await stateMachine.conditionalTransitions();

    currentState = await stateMachine.getCurrentStateId.call();
    assert.equal(web3.toUtf8(currentState), stateA);

    await stateMachine.setDummyCondition(stateA, stateB);
    await stateMachine.conditionalTransitions();
    
    currentState = await stateMachine.getCurrentStateId.call();
    assert.equal(web3.toUtf8(currentState), stateB);

    await stateMachine.setDummyVariableCondition(stateB, stateC);
    await stateMachine.conditionalTransitions();

    currentState = await stateMachine.getCurrentStateId.call();
    assert.equal(web3.toUtf8(currentState), stateB);

    await stateMachine.setCondition(true);
    await stateMachine.conditionalTransitions();

    currentState = await stateMachine.getCurrentStateId.call();
    assert.equal(web3.toUtf8(currentState), stateC);
  });

  it('should automatically perform multiple transitions if there exist consecutive transitions with conditions that evaluate to true', async () => {
    let currentState;
    currentState = await stateMachine.getCurrentStateId.call();
    assert.equal(web3.toUtf8(currentState), stateA);

    await stateMachine.conditionalTransitions();

    currentState = await stateMachine.getCurrentStateId.call();
    assert.equal(web3.toUtf8(currentState), stateA);

    await stateMachine.setDummyCondition(stateA, stateB);
    await stateMachine.setDummyCondition(stateB, stateC);
    await stateMachine.setDummyCondition(stateC, stateD);
    await stateMachine.conditionalTransitions();
    
    currentState = await stateMachine.getCurrentStateId.call();
    assert.equal(web3.toUtf8(currentState), stateD);
  });

  it('should go to FALLBACK state if a cycle of automatic transitions has occurred', async () => {
    let currentState;
    currentState = await stateMachine.getCurrentStateId.call();
    assert.equal(web3.toUtf8(currentState), stateA);

    await stateMachine.conditionalTransitions();

    currentState = await stateMachine.getCurrentStateId.call();
    assert.equal(web3.toUtf8(currentState), stateA);

    await stateMachine.setDummyCondition(stateA, stateB);
    await stateMachine.setDummyCondition(stateB, stateC);
    await stateMachine.setDummyCondition(stateC, stateD);
    await stateMachine.setDummyCondition(stateD, stateA);
    await stateMachine.conditionalTransitions();
    
    currentState = await stateMachine.getCurrentStateId.call();
    assert.equal(currentState, fallbackState);   
  });

  it('should be possible to set a callback for a state', async () => {
    let callbackCalled;
    callbackCalled = await stateMachine.callbackCalled.call();
    assert.isFalse(callbackCalled);

    await stateMachine.setDummyStateCallback(stateB);
    callbackCalled = await stateMachine.callbackCalled.call();
    assert.isFalse(callbackCalled);

    await stateMachine.goToStateHelper(stateB);
    callbackCalled = await stateMachine.callbackCalled.call();
    assert.isTrue(callbackCalled);
  });

  it('should be possible to set a callback for a transition', async () => {
    let callbackCalled;
    callbackCalled = await stateMachine.callbackCalled.call();
    assert.isFalse(callbackCalled);

    // Set a callback that is only run when going from B to C
    await stateMachine.setDummyTransitionCallback(stateB, stateC);
    callbackCalled = await stateMachine.callbackCalled.call();
    assert.isFalse(callbackCalled);

    // Should not run the callback as we are transitioning from A to C
    await stateMachine.goToStateHelper(stateC);
    callbackCalled = await stateMachine.callbackCalled.call();
    assert.isFalse(callbackCalled);

    // Go to B and then to C to run the callback
    await stateMachine.goToStateHelper(stateB);
    callbackCalled = await stateMachine.callbackCalled.call();
    assert.isFalse(callbackCalled);

    await stateMachine.goToStateHelper(stateC);
    callbackCalled = await stateMachine.callbackCalled.call();
    assert.isTrue(callbackCalled);
  });

});
