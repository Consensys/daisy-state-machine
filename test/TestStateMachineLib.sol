pragma solidity 0.4.19;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/StateMachineLib.sol";


contract TestStateMachineLib {
    using StateMachineLib for StateMachineLib.StateMachine;

    bytes32 constant STATE0 = "state0";
    bytes32 constant STATE1a = "state1a";
    bytes32 constant STATE1b = "state1b";
    bytes32 constant STATE2 = "state2";
    bytes32 constant STATE3 = "state3";

    // States that will override existing states
    bytes32 constant STATEOVERRIDE1b = "override1b";
    bytes32 constant STATEOVERRIDE2 = "override2";
    bytes32 constant STATEOVERRIDE3 = "override3";

    StateMachineLib.StateMachine stateMachine;

    mapping(bytes32 => bool) dummyCallbackCalled;

    function dummyCallback1a() internal { 
        dummyCallbackCalled[STATE1a] = true; 
    }

    function dummyCallback1b() internal { 
        dummyCallbackCalled[STATE1b] = true; 
    }

    function dummyCallback2() internal { 
        dummyCallbackCalled[STATE2] = true; 
    }

    function dummyCallback3() internal { 
        dummyCallbackCalled[STATE3] = true; 
    }


    function dummy() public pure {}

    function beforeEach() public {

        stateMachine = StateMachineLib.StateMachine(0);
        stateMachine.setStates(states);

        dummyCallbackCalled[STATE1a] = false;
        dummyCallbackCalled[STATE1b] = false;
        dummyCallbackCalled[STATE2] = false;
        dummyCallbackCalled[STATE3] = false;
        dummyCallbackCalled[STATEOVERRIDE1b] = false;
        dummyCallbackCalled[STATEOVERRIDE2] = false;
        dummyCallbackCalled[STATEOVERRIDE3] = false;
    }

    function testStatesShouldBeValid() public {
        Assert.isTrue(stateMachine.validState[STATE1a], "STATE1a should be valid");
        Assert.isTrue(stateMachine.validState[STATE1b], "STATE1b should be valid");
        Assert.isTrue(stateMachine.validState[STATE2], "STATE2 should be valid");
        Assert.isTrue(stateMachine.validState[STATE3], "STATE3 should be valid");
    }

    function testTransitionsShouldWork() public {
        Assert.equal(stateMachine.currentStateId, STATE1, "StateMachine should start at STATE1");

        stateMachine.goToNextState();
        Assert.equal(stateMachine.currentStateId, STATE2, "StateMachine should have transitioned to STATE2");

        stateMachine.goToNextState();
        Assert.equal(stateMachine.currentStateId, STATE3, "StateMachine should have transitioned to STATE3");

        stateMachine.goToNextState();
        Assert.equal(stateMachine.currentStateId, STATE4, "StateMachine should have transitioned to STATE4");
    }

    function testAllowedFunctions() public {
        bool allowed = false;
        bytes4 selector = this.dummy.selector;
        
        stateMachine.allowFunction(STATE3, selector);

        allowed = stateMachine.checkAllowedFunction(selector);
        Assert.isFalse(allowed, "Dummy function should not be allowed in STATE1");

        stateMachine.goToNextState();
        allowed = stateMachine.checkAllowedFunction(selector);
        Assert.isFalse(allowed, "Dummy function should not be allowed in STATE2");

        stateMachine.goToNextState();
        allowed = stateMachine.checkAllowedFunction(selector);
        Assert.isTrue(allowed, "Dummy function should be allowed in STATE3");

        stateMachine.goToNextState();
        allowed = stateMachine.checkAllowedFunction(selector);
        Assert.isFalse(allowed, "Dummy function should not be allowed in STATE4");
    }

    function testStateCallbacksShouldBeCalled() public {

        Assert.isFalse(dummyCallbackCalled[STATE2], "dummyCallback should not have been called before STATE2");
        stateMachine.addCallback(STATE2,dummyCallback2);
        stateMachine.goToNextState();
        Assert.isTrue(dummyCallbackCalled[STATE2], "dummyCallback should have been called when entering STATE2");

        Assert.isFalse(dummyCallbackCalled[STATE3], "dummyCallback should not have been called before STATE3");
        stateMachine.addCallback(STATE3,dummyCallback3);
        stateMachine.goToNextState();
        Assert.isTrue(dummyCallbackCalled[STATE3], "dummyCallback should have been called when entering STATE3");

        Assert.isFalse(dummyCallbackCalled[STATE4], "dummyCallback should not have been called before STATE4");
        stateMachine.addCallback(STATE4,dummyCallback4);
        stateMachine.goToNextState();
        Assert.isTrue(dummyCallbackCalled[STATE4], "dummyCallback should have been called when entering STATE4");
    }

    // Override state 2 with 3 different states
    function testOverridingStatesShouldWork() public {

        // We are "bypassing" STATE2 by creating transitions STATE1 -> STATEOVERRIDE1 -> STATEOVERRIDE2 -> STATEOVERRIDE3 -> STATE3
        stateMachine.createTransition(STATE1, STATEOVERRIDE1);
        stateMachine.createTransition(STATEOVERRIDE1, STATEOVERRIDE2);
        stateMachine.createTransition(STATEOVERRIDE2, STATEOVERRIDE3);
        stateMachine.createTransition(STATEOVERRIDE3, STATE3);

        Assert.isFalse(stateMachine.validState[STATE2], "STATE2 should have become invalid");

        stateMachine.goToNextState();
        Assert.equal(stateMachine.currentStateId, STATEOVERRIDE1, "stateMachine should have transitioned to STATEOVERRIDE1 (instead of STATE2) from STATE1");

        stateMachine.goToNextState();
        Assert.equal(stateMachine.currentStateId, STATEOVERRIDE2, "stateMachine should have transitioned to STATEOVERRIDE2 from STATEOVERRIDE1");

        stateMachine.goToNextState();
        Assert.equal(stateMachine.currentStateId, STATEOVERRIDE3, "stateMachine should have transitioned to STATEOVERRIDE3 from STATEOVERRIDE2");

        stateMachine.goToNextState();
        Assert.equal(stateMachine.currentStateId, STATE3, "stateMachine should have transitioned to STATE3 from STATEOVERRIDE3");

        Assert.isFalse(dummyCallbackCalled[STATE2], "STATE2's callback should not have been called");
    }
}

