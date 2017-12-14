# sapienico
[![Build Status](https://travis-ci.com/eshohet/sapien-contracts.svg?token=e4rLA2hbyesf7xbp729b&branch=master)](https://travis-ci.com/eshohet/sapien-contracts)
## Information

This repository contains smart contracts that Sapien.me will use for the presale and ICO and to manage the SPN token utility.

## Setup
```bash
npm install
npm run eth_install
```
## Deploying
```bash
ganache-cli -l 10000000 testrpc
truffle compile
truffle migrate
```

## Testing

```bash
truffle test
```
Keep in mind that some tests have special cases where you need to modify the smart contract code in order to let the tests pass.
