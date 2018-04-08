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
    await timedStateMachine.setInitialStateHelper(state0);
    await timedStateMachine.createTransitionHelper(state0, state1);
    await timedStateMachine.createTransitionHelper(state0, state2);
    await timedStateMachine.createTransitionHelper(state1, state2);
    await timedStateMachine.createTransitionHelper(state1, state3);
  });

  it('should not be possible to set a start time lower than the current one', async () => {
    const timestamp = (await latestTime()) - duration.weeks(1);
    await expectThrow(timedStateMachine.setTransitionStartTimeHelper(state0, state1, timestamp));
    await expectThrow(timedStateMachine.setTransitionStartTimeHelper(state0, state2, timestamp));
    await expectThrow(timedStateMachine.setTransitionStartTimeHelper(state1, state2, timestamp));
    await expectThrow(timedStateMachine.setTransitionStartTimeHelper(state1, state3, timestamp));
  });

  it('should be possible to set a start time before any start condition is set', async () => {
    const timestamp = (await latestTime()) + duration.weeks(1);

    await timedStateMachine.setTransitionStartTimeHelper(state1, state2, timestamp);

    const _timestamp = await timedStateMachine.getTransitionStartTime.call(state1, state2);

    assert.equal(timestamp, _timestamp);

  });

  it('should transition to the next state if the set timestamp is reached', async () => {
    const timestamp = (await latestTime()) + duration.weeks(1);
    await timedStateMachine.setTransitionStartTimeHelper(state0, state1, timestamp);

    await increaseTime(duration.weeks(2));
    await timedStateMachine.conditionalTransitionHelper();

    let currentState = web3.toUtf8(await timedStateMachine.currentStateId.call());
    assert.equal(currentState, state1);

    await timedStateMachine.conditionalTransitionHelper(); //calling it again should not affect the expected result

    currentState = web3.toUtf8(await timedStateMachine.currentStateId.call());
    assert.equal(currentState, state1);

  });

  it('should be possible to set a start time (and set a start time) before any transition is set', async () => {
    timedStateMachine = await TimedStateMachineMock.new();
    await timedStateMachine.setInitialStateHelper(state0);
    const timestamp = (await latestTime()) + duration.weeks(1);

    await timedStateMachine.setTransitionStartTimeHelper(state0, state1, timestamp);

    await increaseTime(duration.weeks(2));

    await timedStateMachine.conditionalTransitionHelper(); 

    let currentState = web3.toUtf8(await timedStateMachine.currentStateId.call());
    assert.equal(currentState, state1);

  });

});
