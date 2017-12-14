let Owned = artifacts.require('contracts/Owned.sol');
let SapienToken = artifacts.require('contracts/SapienToken.sol');
let SPNStorage = artifacts.require('contracts/storage/SPNStorage.sol');
let SapienStaking = artifacts.require('contracts/storage/SapienStaking.sol');

const assertFail = require("./helpers/assertFail");

contract('SapienToken', function(accounts) {
    
    let owned;
    let spnStorage;
    let token;
    let controller;

    const tokenAmount = 30 * 10 ** 18;
    
    beforeEach(async () => {
            
        owned = await Owned.new({from: accounts[0]});
    
        spnStorage = await SPNStorage.new(Owned.address, {from: accounts[0]});
    
        token = await SapienToken.new(owned.address, tokenAmount, {from: accounts[0]});
    
        await spnStorage.addContract(token.address, {from: accounts[0]});
    
        await token.changeController(controller.address, {from: accounts[0]});
    
        await token.changeSPNStorage(spnStorage.address, {from: accounts[0]});        
    
    });

    it("SapienToken deployed with SPN symbol", async function() {
        let symbol = await token.symbol.call();

        assert.equal(symbol, 'SPN', 'Symbol name is not SPN');
    });

    

});