import expectThrow from './helpers/expectThrow';

const StateMachineLib = artifacts.require('StateMachineLib');
const StateMachineMock = artifacts.require('StateMachineMock');

contract('StateMachine', accounts => {
  let stateMachine;
  const invalidStage = 'invalid';
  const stage0 = 'STAGE0';
  const stage1 = 'STAGE1';
  const stage2 = 'STAGE2';
  const stage3 = 'STAGE3';
  let dummyFunctionSelector;


  beforeEach(async () => {
    const stateMachineLib = await StateMachineLib.new();
    StateMachineMock.link('StateMachineLib', stateMachineLib.address);
    stateMachine = await StateMachineMock.new();
    await stateMachine.setStagesHelper([stage0, stage1, stage2, stage3]);
    dummyFunctionSelector = await stateMachine.dummyFunctionSelector.call();
  });

  it('should not be possible to set an initial stage if there is already one', async () => {
    await expectThrow(stateMachine.setStagesHelper([invalidStage]));
  });

  it('should not be possible to use an empty array for setting the stages', async () => {
    stateMachine = await StateMachineMock.new();
    await expectThrow(stateMachine.setStagesHelper([]));
  });

  it('should not be possible to create a transition from an invalid stage', async () => {
    await expectThrow(stateMachine.createTransition(invalidStage, stage0));
  });

  it('should not be possible to allow a function for an invalid stage', async () => {
    await expectThrow(stateMachine.allowFunction(invalidStage, dummyFunctionSelector));
  });

  it('should be possible to allow a function for a valid stage', async () => {
    await stateMachine.allowFunction(stage0, dummyFunctionSelector);
    await stateMachine.allowFunction(stage1, dummyFunctionSelector);
    await stateMachine.allowFunction(stage2, dummyFunctionSelector);
    await stateMachine.allowFunction(stage3, dummyFunctionSelector);
  });

  it('should not be possible to call an unallowed function', async () => {
    await expectThrow(stateMachine.dummyFunction());
  });

  it('should be possible to call an allowed function', async () => {
    await stateMachine.allowFunction(stage0, dummyFunctionSelector);
    await stateMachine.dummyFunction();
  });

  // TODO: review this.. it improves coverage but it doesn't seem necessary
  it('should not perform conditional transitions at any stage', async () => {
    let currentStage;
    currentStage = await stateMachine.getCurrentStageId.call();
    assert.equal(web3.toUtf8(currentStage), stage0);

    await stateMachine.conditionalTransitions();

    currentStage = await stateMachine.getCurrentStageId.call();
    assert.equal(web3.toUtf8(currentStage), stage0);

    await stateMachine.goToNextStageHelper();
    currentStage = await stateMachine.getCurrentStageId.call();
    assert.equal(web3.toUtf8(currentStage), stage1);

    await stateMachine.conditionalTransitions();

    currentStage = await stateMachine.getCurrentStageId.call();
    assert.equal(web3.toUtf8(currentStage), stage1);

    await stateMachine.goToNextStageHelper();
    currentStage = await stateMachine.getCurrentStageId.call();
    assert.equal(web3.toUtf8(currentStage), stage2);

    await stateMachine.conditionalTransitions();

    currentStage = await stateMachine.getCurrentStageId.call();
    assert.equal(web3.toUtf8(currentStage), stage2);

    await stateMachine.goToNextStageHelper();
    currentStage = await stateMachine.getCurrentStageId.call();
    assert.equal(web3.toUtf8(currentStage), stage3);

    await stateMachine.conditionalTransitions();

    currentStage = await stateMachine.getCurrentStageId.call();
    assert.equal(web3.toUtf8(currentStage), stage3);
  });

  it('should not be possible to set a start condition for an invalid stage', async () => {
    await expectThrow(stateMachine.setDummyCondition(invalidStage));
    await expectThrow(stateMachine.setDummyVariableCondition(invalidStage));
  });

  it('should automatically go to a stage with a condition that evaluates to true', async () => {
    let currentStage;
    currentStage = await stateMachine.getCurrentStageId.call();
    assert.equal(web3.toUtf8(currentStage), stage0);

    await stateMachine.conditionalTransitions();

    currentStage = await stateMachine.getCurrentStageId.call();
    assert.equal(web3.toUtf8(currentStage), stage0);

    await stateMachine.setDummyCondition(stage1);
    await stateMachine.conditionalTransitions();

    currentStage = await stateMachine.getCurrentStageId.call();
    assert.equal(web3.toUtf8(currentStage), stage1);

    await stateMachine.setDummyVariableCondition(stage2);
    await stateMachine.conditionalTransitions();

    currentStage = await stateMachine.getCurrentStageId.call();
    assert.equal(web3.toUtf8(currentStage), stage1);

    await stateMachine.setCondition(true);
    await stateMachine.conditionalTransitions();

    currentStage = await stateMachine.getCurrentStageId.call();
    assert.equal(web3.toUtf8(currentStage), stage2);
  });

  it('should not be possible to set a callback for an invalid stage', async () => {
    await expectThrow(stateMachine.setDummyCallback(invalidStage));
  });

  it('should be possible to set a callback for a valid stage', async () => {
    let callbackCalled;
    callbackCalled = await stateMachine.callbackCalled.call();
    assert.isFalse(callbackCalled);

    await stateMachine.setDummyCallback(stage1);
    callbackCalled = await stateMachine.callbackCalled.call();
    assert.isFalse(callbackCalled);

    await stateMachine.goToNextStageHelper();
    callbackCalled = await stateMachine.callbackCalled.call();
    assert.isTrue(callbackCalled);
  });

  it('should not be possible to go to next stage when in the last stage', async () => {
    // Go to stage 1
    await stateMachine.goToNextStageHelper();
    // Go to stage 2
    await stateMachine.goToNextStageHelper();
    // Go to stage 3
    await stateMachine.goToNextStageHelper();
    // Should throw because stage 3 is the last stage
    await expectThrow(stateMachine.goToNextStageHelper());
  });
});
