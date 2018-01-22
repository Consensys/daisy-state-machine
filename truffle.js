require('babel-register');
require('babel-polyfill');

const getPrivateKey = require('./utils/get-private-key');

const HDWalletProvider = require('./utils/truffle-provider');

const provider = (url) => {
  const address = process.env.ADDRESS;
  const password = process.env.PASSWORD;
  const privateKey = address && password ? getPrivateKey(address, password) : null;
  return privateKey ? () => new HDWalletProvider(privateKey, url) : null;
};

module.exports = {
  networks: {
    local: {
      host: 'localhost',
      network_id: '*',
      port: 8545,
      provider: provider('http://127.0.0.1:8545')   
    },
    coverage: {
      host: 'localhost',
      network_id: '*',
      port: 8555,
      gas: 0xfffffffffff,
      gasPrice: 0x01
    },
    rinkeby: {
      gas: 6000000,
      network_id: 4,
      provider: provider('https://rinkeby.infura.io/' + process.env.INFURA),
    },
    mainnet: {
      gas: 6000000,
      network_id: 1,
      provider: provider('https://mainnet.infura.io/' + process.env.INFURA),
    }
  },
  solc: {
    optimizer: {
      enabled: true,
      runs: 200
    }
  }
};
