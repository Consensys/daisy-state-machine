const StateMachineLib = artifacts.require('StateMachineLib.sol');

module.exports = function (deployer, network, accounts) {
  deployer.deploy(StateMachineLib);
};
