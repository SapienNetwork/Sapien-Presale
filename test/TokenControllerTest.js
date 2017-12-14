let TokenController = artifacts.require('contracts/TokenController.sol');
let Owned = artifacts.require('contracts/Owned.sol');
let SapienToken = artifacts.require('contracts/SapienToken.sol');
let SapienCrowdsale = artifacts.require('contracts/SapienCrowdsale.sol');
let SPNStorage = artifacts.require('contracts/storage/SPNStorage.sol');

const assertFail = require("./helpers/assertFail");

contract('TokenController', function(accounts) {

    let owned;
    let spnStorage;
    let token;
    let controller;

    const tokenAmount = 30 * 10 ** 18;

    beforeEach(async () => {
        
        owned = await Owned.new({from: accounts[0]});

        spnStorage = await SPNStorage.new(Owned.address, {from: accounts[0]});

        token = await SapienToken.new(owned.address, tokenAmount, {from: accounts[0]});

        controller = await TokenController.new(token.address, owned.address, {from: accounts[0]});

        await spnStorage.addContract(token.address, {from: accounts[0]});

        await token.changeController(controller.address, {from: accounts[0]});

        await token.changeSPNStorage(spnStorage.address, {from: accounts[0]});        

    });

    it("SapienToken deployed with SPN symbol", async function() {
        let symbol = await token.symbol.call();

        assert.equal(symbol, 'SPN', 'Symbol name is not SPN');
    });

    it("Only owner can do certain actions", async function() {
        
        await assertFail(async function() {
            await controller.changeSPNToken(accounts[2], {from: accounts[1]});
        });

        await assertFail(async function() {
            await controller.changeOwned(accounts[1], {from: accounts[1]});
        });

        await assertFail(async function() {
            await controller.changeCrowdsale(accounts[2], {from: accounts[1]});
        });

    });

    it("Owner can allocate tokens", async function() {

        await controller.allocateTokens(accounts[1], 100, {from: accounts[0]});

        let circulation = await token.currentlyInCirculation.call();

        assert.equal(100, circulation);

        assert.equal(100, await token.balanceOf(accounts[1]));

    });

});
