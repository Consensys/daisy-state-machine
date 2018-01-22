const Wallet = require('ethereumjs-wallet');
const fs = require('fs');
const path = require('path');
const inquirer = require('inquirer');
const keystore = path.resolve('.keys');

if (!fs.existsSync(keystore))
  fs.mkdirSync(keystore);

inquirer.prompt([
  { type: 'password', name: 'password', message: 'Password' }
]).then(answers => {
  console.log('Creating Wallet...');
  const wallet = Wallet.generate();
  console.log('Wallet Created:');
  console.log('Address:', '0x' + wallet.getAddress().toString('hex'));
  // console.log(wallet.mnemonic.toLowerCase());
  console.log('Encrypting...');
  return wallet.toV3(answers.password);
}).then(v3 => {
  const address = '0x' + v3.address;
  const fname = path.join(keystore, (address + '.json').toLowerCase());
  fs.writeFileSync(fname, JSON.stringify(v3));
  console.log('Encrypted wallet stored in', fname);
});
