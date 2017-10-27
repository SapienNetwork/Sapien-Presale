var SapienCoin = artifacts.require('./SapienCoin.sol');
var MultisigWallet = artifacts.require('./MultisigWallet.sol');
var SapienCrowdsale = artifacts.require('./SapienCrowdsale.sol');

module.exports = async function(deployer, network, accounts) {

    const startBlock = web3.eth.blockNumber + 300;
    const endBlock = startBlock + 300;
    const rate = new web3.BigNumber(1000);
    const cap = new web3.BigNumber(73000000000000000000000); //83k ether hardcap

    deployer.deploy(SapienCoin, {from: accounts[0]});
    deployer.deploy(MultisigWallet, [accounts[0], accounts[1], accounts[2]], {from: accounts[0]});
    deployer.deploy(SapienCrowdsale, {from: accounts[0]});

    //set Crowdsale as current controller, allowing the crowdsale to mint new tokens
    await web3.eth.contract(SapienCoin.abi).at(SapienCoin.address)
        .changeController(SapienCrowdsale.address, {from: accounts[0]});

    //initalize crowdsale
    await web3.eth.contract(SapienCrowdsale.abi).at(SapienCrowdsale.address)
        .initalize(startBlock, endBlock, rate, MultisigWallet.address, cap, SapienCoin.address, {from: accounts[0], gas: 1930000});

};
