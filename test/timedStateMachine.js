import increaseTime, { duration } from './helpers/increaseTime';
import latestTime from './helpers/latestTime';
import expectThrow from './helpers/expectThrow';

const StateMachineLib = artifacts.require('StateMachineLib');
const TimedStateMachineMock = artifacts.require('TimedStateMachineMock');

contract('TimedStateMachine', accounts => {
  let timedStateMachine;
  let invalidStage = 'invalid';
  let stage0 = 'STAGE0';
  let stage1 = 'STAGE1';
  let stage2 = 'STAGE2';
  let stage3 = 'STAGE3';

  beforeEach(async () => {
    const stateMachineLib = await StateMachineLib.new();
    TimedStateMachineMock.link('StateMachineLib', stateMachineLib.address);
    timedStateMachine = await TimedStateMachineMock.new();
  });

   
  it('should not be possible to set the start time for an invalid stage', async () => {
    const timestamp = (await latestTime()) + duration.weeks(1);
    await expectThrow(timedStateMachine.setStageStartTimeHelper(invalidStage, timestamp));
  });

  it('should not be possible to set a start time lower than the current one', async () => {
    const timestamp = (await latestTime()) - duration.weeks(1);
    await expectThrow(timedStateMachine.setStageStartTimeHelper(stage0, timestamp));
    await expectThrow(timedStateMachine.setStageStartTimeHelper(stage1, timestamp));
    await expectThrow(timedStateMachine.setStageStartTimeHelper(stage2, timestamp));
    await expectThrow(timedStateMachine.setStageStartTimeHelper(stage3, timestamp));
  });

  it('should be possible to set a start time', async () => {
    const timestamp = (await latestTime()) + duration.weeks(1);

    await timedStateMachine.setStageStartTimeHelper(stage1, timestamp);

    const _timestamp = await timedStateMachine.getStageStartTime.call(stage1);

    assert.equal(timestamp, _timestamp);

  });

  it('should transition to the next stage if the set timestamp is reached', async () => {
    const timestamp = (await latestTime()) + duration.weeks(1);

    await timedStateMachine.setStageStartTimeHelper(stage1, timestamp);

    await increaseTime(duration.weeks(2));

    await timedStateMachine.conditionalTransitions();

    let currentStage = web3.toUtf8(await timedStateMachine.getCurrentStageId.call());

    assert.equal(currentStage, stage1);

    await timedStateMachine.conditionalTransitions(); //calling it again should not affect the expected result

    currentStage = web3.toUtf8(await timedStateMachine.getCurrentStageId.call());

    assert.equal(currentStage, stage1);

  });
});
