pragma solidity 0.4.19;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/StateMachineLib.sol";


contract TestStateMachineLib {
    using StateMachineLib for StateMachineLib.StateMachine;

    bytes32 constant STATE0 = "state0";
    bytes32 constant STATE1A = "state1a";
    bytes32 constant STATE1B = "state1b";
    bytes32 constant STATE2 = "state2";
    bytes32 constant STATE3 = "state3";
    bytes32 constant ALTSTATE = "altstate";


    StateMachineLib.StateMachine stateMachine;

    mapping(bytes32 => bool) dummyCallbackCalled;

    function dummyCallback1A() internal { 
        dummyCallbackCalled[STATE1A] = true; 
    }

    function dummyCallback1B() internal { 
        dummyCallbackCalled[STATE1B] = true; 
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
        stateMachine.setInitialState(STATE0);
        stateMachine.createTransition(STATE0, STATE1A);
        stateMachine.createTransition(STATE0, STATE1B);
        stateMachine.createTransition(STATE1A, STATE2);
        stateMachine.createTransition(STATE1B, STATE2);
        stateMachine.createTransition(STATE2, STATE3);

        dummyCallbackCalled[STATE1A] = false;
        dummyCallbackCalled[STATE1B] = false;
        dummyCallbackCalled[STATE2] = false;
        dummyCallbackCalled[STATE3] = false;
    }

    function testStatesShouldBeValid() public {
        Assert.isTrue(stateMachine.validState[STATE1A], "STATE1A should be valid");
        Assert.isTrue(stateMachine.validState[STATE1B], "STATE1B should be valid");
        Assert.isTrue(stateMachine.validState[STATE2], "STATE2 should be valid");
        Assert.isTrue(stateMachine.validState[STATE3], "STATE3 should be valid");
    }

    function testTransitionsShouldWork() public {
        Assert.equal(stateMachine.currentStateId, STATE0, "StateMachine should start at STATE0");

        stateMachine.goToNextState(STATE1B);
        Assert.equal(stateMachine.currentStateId, STATE1B, "StateMachine should have transitioned to STATE1B");

        //stateMachine.goToNextState(STATE1A);
        Assert.equal(stateMachine.currentStateId, STATE1B, "StateMachine should not have transitioned out of STATE1B");

        stateMachine.goToNextState(STATE2);
        Assert.equal(stateMachine.currentStateId, STATE2, "StateMachine should have transitioned to STATE2");

        stateMachine.createTransition(STATE2, ALTSTATE);
        stateMachine.goToNextState(ALTSTATE);
        Assert.equal(stateMachine.currentStateId, ALTSTATE, "StateMachine should have transitioned to ALTSTATE");

        //stateMachine.goToNextState(STATE3);
        Assert.equal(stateMachine.currentStateId, ALTSTATE, "StateMachine should not have transitioned out of ALTSTATE");
    }

    function testAllowedFunctions() public {
        bool allowed = false;
        bytes4 selector = this.dummy.selector;
        
        stateMachine.allowFunction(STATE3, selector);

        allowed = stateMachine.checkAllowedFunction(selector);
        Assert.isFalse(allowed, "Dummy function should not be allowed in STATE0");
        
        stateMachine.goToNextState(STATE1A);
        allowed = stateMachine.checkAllowedFunction(selector);
        Assert.isFalse(allowed, "Dummy function should not be allowed in STATE1A");  

        stateMachine.goToNextState(STATE2);
        allowed = stateMachine.checkAllowedFunction(selector);
        Assert.isFalse(allowed, "Dummy function should not be allowed in STATE2");

        stateMachine.goToNextState(STATE3);
        allowed = stateMachine.checkAllowedFunction(selector);
        Assert.isTrue(allowed, "Dummy function should be allowed in STATE3");

    }

    function testStateCallbacksShouldBeCalled() public {
        Assert.isFalse(dummyCallbackCalled[STATE0], "dummyCallback should not have been called before STATE0");
        stateMachine.addCallback(STATE1A,dummyCallback1A);
        stateMachine.goToNextState(STATE1A);
        Assert.isTrue(dummyCallbackCalled[STATE1A], "dummyCallback should have been called when entering STATE1A");

        Assert.isFalse(dummyCallbackCalled[STATE2], "dummyCallback should not have been called before STATE2");
        stateMachine.addCallback(STATE2,dummyCallback2);
        stateMachine.goToNextState(STATE2);
        Assert.isTrue(dummyCallbackCalled[STATE2], "dummyCallback should have been called when entering STATE2");

        Assert.isFalse(dummyCallbackCalled[STATE3], "dummyCallback should not have been called before STATE3");
        stateMachine.addCallback(STATE3,dummyCallback3);
        stateMachine.goToNextState(STATE3);
        Assert.isTrue(dummyCallbackCalled[STATE3], "dummyCallback should have been called when entering STATE3");

    }

    
}

