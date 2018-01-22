import { duration } from './helpers/increaseTime';
import latestTime from './helpers/latestTime';
import expectThrow from './helpers/expectThrow';
import PromisifyWeb3 from './helpers/promisifyWeb3';

PromisifyWeb3.promisify(web3);

const TimedStateMachineMock = artifacts.require('TimedStateMachineMock.sol');

contract('TimedStateMachine', accounts => {
  let timedStateMachine;
  let invalidStage = 'invalid';
  let stage0 = 'STAGE0';
  let stage1 = 'STAGE1';
  let stage2 = 'STAGE2';
  let stage3 = 'STAGE3';

  beforeEach(async () => {
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
});
