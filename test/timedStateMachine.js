import increaseTime, { duration } from './helpers/increaseTime';
import latestTime from './helpers/latestTime';
import expectThrow from './helpers/expectThrow';

const TimedStateMachineMock = artifacts.require('TimedStateMachineMock');

contract('TimedStateMachine', accounts => {
  let timedStateMachine;
  let state0 = 'STATE0';
  let state1 = 'STATE1';
  let state2 = 'STATE2';
  let state3 = 'STATE3';

  beforeEach(async () => {
    timedStateMachine = await TimedStateMachineMock.new();
  });

  it('should not be possible to set a start time lower than the current one', async () => {
    const timestamp = (await latestTime()) - duration.weeks(1);
    await expectThrow(timedStateMachine.setStateStartTimeHelper(state0, timestamp));
    await expectThrow(timedStateMachine.setStateStartTimeHelper(state1, timestamp));
    await expectThrow(timedStateMachine.setStateStartTimeHelper(state2, timestamp));
    await expectThrow(timedStateMachine.setStateStartTimeHelper(state3, timestamp));
  });

  it('should be possible to set a start time', async () => {
    const timestamp = (await latestTime()) + duration.weeks(1);

    await timedStateMachine.setStateStartTimeHelper(state1, timestamp);

    const _timestamp = await timedStateMachine.getStateStartTime.call(state1);

    assert.equal(timestamp, _timestamp);
  });

  it('should not be possible to set a start time twice for the same state', async () => {
    const timestamp = (await latestTime()) + duration.weeks(1);

    await timedStateMachine.setStateStartTimeHelper(state1, timestamp);

    let _timestamp = await timedStateMachine.getStateStartTime.call(state1);

    assert.equal(timestamp, _timestamp);
    await timedStateMachine.setStateStartTimeHelper(state1, timestamp + 1);

    _timestamp = await timedStateMachine.getStateStartTime.call(state1);
    assert.equal(timestamp + 1, _timestamp);
  });

  it('should transition to the next state if the set timestamp is reached', async () => {
    const timestamp = (await latestTime()) + duration.weeks(1);

    await timedStateMachine.setStateStartTimeHelper(state1, timestamp);

    await increaseTime(duration.weeks(2));

    await timedStateMachine.conditionalTransitions();

    let currentState = web3.toUtf8(await timedStateMachine.currentStateId.call());

    assert.equal(currentState, state1);

    await timedStateMachine.conditionalTransitions(); //calling it again should not affect the expected result

    currentState = web3.toUtf8(await timedStateMachine.currentStateId.call());

    assert.equal(currentState, state1);

  });
});
