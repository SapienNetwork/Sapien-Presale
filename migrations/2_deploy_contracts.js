let SapienCrowdsale = artifacts.require("./SapienCrowdSale.sol");
let SapienCoin = artifacts.require('./SapienCoin.sol');

module.exports = async function(deployer, network, accounts) {

    const startBlock = web3.eth.blockNumber + 300;
    const endBlock = startBlock + 300;
    const rate = new web3.BigNumber(1000);
    const wallet = web3.eth.accounts[0]; //TODO: Add multisignature wallet
    const cap = new web3.BigNumber(83000000000000000000000); //83k ether hardcap

    await deployer.deploy(SapienCoin, {from: accounts[0]});
    await deployer.deploy(SapienCrowdsale, {from: accounts[0]});

    //initalize crowdsale
    await web3.eth.contract(SapienCrowdsale.abi).at(SapienCrowdsale.address)
        .initalize(startBlock, endBlock, rate, wallet, cap, SapienCoin.address, {from: accounts[0], gas: 900000});



};

