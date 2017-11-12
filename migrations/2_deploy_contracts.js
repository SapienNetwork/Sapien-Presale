var Owned = artifacts.require('contracts/Owned.sol');
var StringUtils = artifacts.require('contracts/StringUtils.sol');
var TokenController = artifacts.require('contracts/TokenController.sol');
var MultisigWallet = artifacts.require('contracts/MultisigWallet.sol');
var SapienCrowdsale = artifacts.require('contracts/SapienCrowdsale.sol');
var SapienToken = artifacts.require('node_modules/zeppelin-solidity/contracts/token/SapienToken.sol');
var SapienStaking = artifacts.require('contracts/SapienStaking.sol');

module.exports = async function(deployer, network, accounts) {

    const startBlock = web3.eth.blockNumber + 300;
    const endBlock = startBlock + 300;
    const rate = new web3.BigNumber(1000);
    const cap = new web3.BigNumber(73000000000000000000000); //73k ether hardcap

    deployer.deploy(Owned, { from: accounts[0] });
    deployer.deploy(StringUtils, { from: accounts[0] });
    deployer.deploy(MultisigWallet, [accounts[0], accounts[1], accounts[2]], {from: accounts[0]});
    deployer.deploy(SapienToken, Owned.address, {from: accounts[0]});
    deployer.deploy(TokenController, SapienToken.address, Owned.address, {from: accounts[0]});
    deployer.deploy(SapienCrowdsale, Owned.address, {from: accounts[0]});
    deployer.deploy(SapienStaking, SapienToken.address, Owned.address, {from: accounts[0]});

    //set Crowdsale as current controller, allowing the crowdsale to mint new tokens
    await web3.eth.contract(TokenController.abi).at(TokenController.address)
        .changeCrowdsale(SapienCrowdsale.address, {from: accounts[0]});

    await web3.eth.contract(SapienToken.abi).at(SapienToken.address)
        .changeController(TokenController.address, {from: accounts[0]});

    //initialize crowdsale
    await web3.eth.contract(SapienCrowdsale.abi).at(SapienCrowdsale.address)
        .initialize(startBlock, endBlock, rate, MultisigWallet.address, cap, TokenController.address, {from: accounts[0], gas: 1900000 });

};
