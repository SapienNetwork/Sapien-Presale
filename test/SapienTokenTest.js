let Owned = artifacts.require('contracts/Owned.sol');
let SapienToken = artifacts.require('contracts/SapienToken.sol');
let SPNStorage = artifacts.require('contracts/storage/SPNStorage.sol');
let SapienStaking = artifacts.require('contracts/storage/SapienStaking.sol');
let TokenController = artifacts.require('contracts/TokenController.sol');

const assertFail = require("./helpers/assertFail");

contract('SapienToken', function(accounts) {
    
    let owned;
    let spnStorage;
    let token;
    let controller;
    let staking;

    const tokenAmount = 30 * 10 ** 18;
    
    beforeEach(async () => {
            
        owned = await Owned.new({from: accounts[0]});
    
        spnStorage = await SPNStorage.new(Owned.address, {from: accounts[0]});
    
        token = await SapienToken.new(owned.address, tokenAmount, {from: accounts[0]});
    
        controller = await TokenController.new(token.address, owned.address, {from: accounts[0]});        

        staking = await SapienStaking.new(token.address, owned.address, {from: accounts[0]});

        await spnStorage.addContract(staking.address, {from: accounts[0]});

        await spnStorage.addContract(token.address, {from: accounts[0]});

        await token.changeController(controller.address, {from: accounts[0]});
    
        await token.changeSPNStorage(spnStorage.address, {from: accounts[0]});        
    
        await staking.changeSPNStorage(spnStorage.address, {from: accounts[0]});

    });

    it("SapienToken deployed correctly", async function() {
        
        let symbol = await token.symbol.call();

        assert.equal(symbol, 'SPN', 'Symbol name is not SPN');
    
        assert.equal(await token.name(), "SAPIEN COIN");

        assert.equal(await token.getDecimals(), 18);

        assert.equal(await token.getTotalSupply(), tokenAmount);

    });

    it("SapienToken can stake/unstake tokens", async function() {
        
        await token.enableStaking(staking.address, {from: accounts[0]});

        assert.equal(await token.canStake.call(), 1);

        await token.addToBalance(accounts[1], 100, {from: accounts[0]});

        assert.equal(await token.balanceOf(accounts[1]), 100);

        await token.increaseCirculation(100, {from: accounts[0]});

        await token.transfer(staking.address, 50, "Sent", {from: accounts[1], gas: 1000000});

        assert.equal(await staking.balanceOf(accounts[1]), 50);

        await staking.transfer(token.address, 50, "Sent", {from: accounts[1], gas: 1000000});

        assert.equal(await staking.balanceOf(accounts[1]), 0);        

        assert.equal(await token.balanceOf(accounts[1]), 100);        

    });

    it("Can transfer unstaked tokens between people", async function() {

        await token.addToBalance(accounts[1], 100, {from: accounts[0]});

        await token.increaseCirculation(100, {from: accounts[0]});

        await token.transfer(accounts[2], 50, "Sent", {from: accounts[1], gas: 1000000});

        assert.equal(await token.balanceOf(accounts[2]), 50);

    });

});