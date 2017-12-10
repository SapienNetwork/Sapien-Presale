var Owned = artifacts.require('contracts/Owned.sol');
var StringUtils = artifacts.require('contracts/StringUtils.sol');
var TokenController = artifacts.require('contracts/TokenController.sol');
var MultisigWallet = artifacts.require('contracts/MultisigWallet.sol');
var SapienCrowdsale = artifacts.require('contracts/SapienCrowdsale.sol');
var SapienToken = artifacts.require('contracts/SapienToken.sol');
var SapienStaking = artifacts.require('contracts/SapienStaking.sol');
var DynamicCrowdsale = artifacts.require('contracts/DynamicCrowdsale.sol');
var CrowdsaleStorage = artifacts.require('contracts/storage/CrowdsaleStorage.sol');
var SPNStorage = artifacts.require('contracts/storage/SPNStorage.sol');

module.exports = async function(deployer, network, accounts) {

    const startBlock = web3.eth.blockNumber + 300;
    const endBlock = startBlock + 300;
    const rate = new web3.BigNumber(4000);
    const cap = new web3.BigNumber(2400000000000000000000); //73k ether hardcap

    const premintedTokens = 3 * 10 ** 9;

    deployer.deploy(Owned, { from: accounts[1] });
    deployer.deploy(StringUtils, { from: accounts[1] });
    deployer.deploy(MultisigWallet, [accounts[0], accounts[1], accounts[2]], 2, {from: accounts[2]});
    deployer.deploy(SapienToken, Owned.address, premintedTokens, {from: accounts[4]});
    deployer.deploy(TokenController, SapienToken.address, Owned.address, {from: accounts[1]});
    deployer.deploy(SapienCrowdsale, Owned.address, {from: accounts[0], gas: 40900000});
    deployer.deploy(SapienStaking, SapienToken.address, Owned.address, {from: accounts[1]});
    deployer.deploy(DynamicCrowdsale, Owned.address, {from: accounts[2]});
    deployer.deploy(CrowdsaleStorage, Owned.address, {from: accounts[2]});
    deployer.deploy(SPNStorage, Owned.address, {from: accounts[3]});

    //set Crowdsale as current controller, allowing the crowdsale to mint new tokens
    await web3.eth.contract(TokenController.abi).at(TokenController.address)
        .changeCrowdsale(SapienCrowdsale.address, {from: accounts[0]});

    await web3.eth.contract(TokenController.abi).at(TokenController.address)
        .changeSPNToken(SapienCrowdsale.address, {from: accounts[0]});

    await web3.eth.contract(SapienToken.abi).at(SapienToken.address)
        .changeController(TokenController.address, {from: accounts[0]});

    await web3.eth.contract(SapienToken.abi).at(SapienToken.address)
        .changeSPNStorage(SPNStorage.address, {from: accounts[0]});

    //initialize crowdsale
    await web3.eth.contract(SapienCrowdsale.abi).at(SapienCrowdsale.address)
        .initialize(startBlock, endBlock, rate, MultisigWallet.address, cap, TokenController.address, CrowdsaleStorage.address, {from: accounts[0], gas: 1900000 });

    await web3.eth.contract(SapienCrowdsale.abi).at(SapienCrowdsale.address)
        .changeDynamic(DynamicCrowdsale.address, {from: accounts[0]});

    await web3.eth.contract(SapienStaking.abi).at(SapienStaking.address)
        .changeSPNStorage(SPNStorage.address, {from: accounts[0]});

};
