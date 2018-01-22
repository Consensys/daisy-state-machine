# Pryze - PRYZ - Token

PRYZ is used for interacting with the Pryze platform, allowing users to create and participate in Crypto-Sweepstakes.

## Features

### ERC20

This standard provides basic functionality to transfer tokens, as well as to allow tokens to be spent by other parties.

[ERC20](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md)

### ERC223

This standard allows contracts to handle incoming token transfers and prevent accidentally sent tokens from being locked in contracts.

This standard is in draft status, this means, it is still subject to changes.

[ERC223](https://github.com/ethereum/EIPs/issues/223)

### Mintable

This contract allows increasing PRYZ supply by the owner (the sale contract). This feature is permanently disabled once the sale ends.

We used Open Zeppelin MintableToken.sol contract, you can find it [here](https://github.com/OpenZeppelin/zeppelin-solidity/blob/master/contracts/token/MintableToken.sol)

## Functions

Pryze token inherits from the following contracts: DetailedERC20, MintableToken and ERC223BasicToken.

You can find PRYZ contract [here](https://github.com/tokenfoundry/sale-contracts/blob/develop/contracts/token/PryzeToken.sol)

### modifier onlyOwner()

Prevents a function from being called by an address different to the owner's.

---

### transferOwnership(address newOwner) onlyOwner

Transfers ownership of the contract to the given address. Only the Owner of the token contract can change its ownership.

---

### modifier canMint()

Check if minting feature is still enabled.

---

### mint(address _to, uint256 _amount) onlyOwner canMint public returns (bool)

Increase token balance, only the Owner of the token contract can mint.

---

### finishMinting() onlyOwner canMint public returns (bool)

Disable mint permanently, only the Owner of the token contract can finish minting.

---

### transfer(address _to, uint _value, bytes _data) public returns (bool)

Transfers the specified amount of tokens from sender's account to the specified address. Amount must not be greater than sender's balance. You can add data that will be passed when transfering to a contract.

---
### transfer(address _to, uint256 _value) public returns (bool)

Transfers the specified amount of tokens from sender's account to the specified address. Amount must not be greater than sender's balance.

---

### approve(address _spender, uint256 _value) public returns (bool)

Sets the amount of the sender's token balance that the given address is approved to use.

---

### increaseApproval(address _spender, uint _addedValue) public returns (bool)

Increase the amount of the sender's token balance that the given address is approved to use.

---

### decreaseApproval(address _spender, uint _subtractedValue) public returns (bool)

Decreases the amount of the sender's token balance that the given address is approved to spend.

---

### allowance(address _owner, address _spender)

Returns the approved amount of the owner's balance that the spender can use.

---

### transferFrom(address _from, address _to, uint256 _value) public returns (bool)

Transfers tokens from an account that the sender has approved to transfer from. Amount must not be greater than the approved amount or the account's balance.

---

### balanceOf(address _owner) public view returns (uint256 balance)

Returns the token balance of the given address.
