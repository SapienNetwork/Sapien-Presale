var SapienCrowdsale = artifacts.require("./SapienCrowdSale.sol");

module.exports = function(deployer, network, accounts) {

    const startBlock = web3.eth.blockNumber + 300;
    const endBlock = startBlock + 300;
    const rate = new web3.BigNumber(1000);
    const wallet = web3.eth.accounts[0];

    deployer.deploy(SapienCrowdsale, startBlock, endBlock, rate, wallet);
};