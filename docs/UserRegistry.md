# UserRegistry

UserRegistry is a contract with a mapping of users. For each user, it stores contribution limit, KYC (Know Your Customer) status and if agreed with sale terms. It extends Ownable.sol contract to restrict access to functions that update state variables.
A new user can be registered only when KYC process is done for the user.
User address is the key for a mapping. Mapping will have 3 parameters:
  - lastCheckTimestamp: stores time user was registered or got KYC status variable updated.
  - contributionLimit: default value is **10 ethers**. Max amount an user can contribute in a sale.
  - KYCStatus: default value is **true**.
  - Terms Agreed: default value is **false**.

By default, KYC is valid for a period of 6 months. It is possible to update this period.

For each state change, an event log is created. Here is the list of log events:
```
LogUserRegistered(address indexed sender, address indexed newUserAddress, uint256 newLastTimestamp, uint256 newContributionLimit, bool newKYCStatus);
LogKYCStatusUpdated(address indexed sender, address indexed userAddress, bool newKYCStatus);
LogUserAgreedWithTerms(address indexed sender, address _userAddress, address _sale );
LogUserContributionLimitUpdated(address indexed sender, address userAddress, uint256 oldLimit, uint256 _newLimit);
LogDefaultContributionLimitUpdated(address indexed sender, uint256 oldDefault_contribution, uint256 _newDefaultContributionLimit);        
LogKYCDurationUpdated(address indexed sender, uint256 oldKYC_duration, uint256 newKYC_duration);
```

## Functions

### registerUserWithParams(address userAddress, uint256 contributionLimit, address firstSale) public onlyOwner
---
Only Owner of the contract can register a new user. This function register a new user with
the contribution limit and sale as a parameter. Contribution limit must be greater than 0 or it will revert. Sale address may be 0(zero). KYC status value is set to true because only users that has been passed the KYC process can be registered. Function creates an event log called ``LogUserRegistered``.
   
### registerUser(address userAddress) public onlyOwner
---
Only Owner of the contract can register a new user. A new user gets the default value for contribution limit. KYC value is set to true because only users that has been passed the KYC process can be registered. Function creates an event log called ``LogUserRegistered``.

### getUserInfo(address userAddress, address sale) public view returns(bool KYCStatus, uint256 contributionLimit, bool agreed)
---
If user exists, it returns user information. KYC status is true only if it didn't expired. It
can expire if the last time it was updated is greater than KYC duration (default value is 6 months).

### updateKYCStatus(address userAddress, bool status) public onlyOwner
---
Updates user KYC status. It will revert if user doesn't exist. It creates a log event called ``LogKYCStatusUpdated``.

### agreedWithTerms(address userAddress, address sale) public onlyOwner
---
If user would like to participate in a sale, user must agree with the sale terms. User may participate in more than 1 sale. It will revert if user doesn't exist. It creates a log event called ``LogUserAgreedWithTerms``.

### setContributionLimit(address userAddress, uint256 newContributionlimit) public onlyOwner
---
Sets a new contribution limit to the user. It will revert if user doesn't exist. It creates a log event called ``LogUserContributionLimitUpdated``.

### updateDefaultContributionLimit(uint256 newDefaultContributionLimit) public onlyOwner
---
Updates default contribution limit. It creates a log event called ``LogDefaultContributionLimitUpdated``.

### updateKYC_duration(uint256 newKYC_duration) public onlyOwner
---
Updates KYC duration period. It creates a log event called ``LogKYCDurationUpdated``.