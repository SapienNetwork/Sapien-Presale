let Owned = artifacts.require('contracts/Owned.sol');
let SapienToken = artifacts.require('contracts/SapienToken.sol');
let SPNStorage = artifacts.require('contracts/storage/SPNStorage.sol');
let SapienStaking = artifacts.require('contracts/storage/SapienStaking.sol');
let TokenController = artifacts.require('contracts/TokenController.sol');

const assertFail = require("./helpers/assertFail");

contract('SapienStaking', function(accounts) {
    
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

        await token.enableStaking(staking.address, {from: accounts[0]});
        
        await token.addToBalance(accounts[1], 100, {from: accounts[0]});
        
        await token.increaseCirculation(100, {from: accounts[0]});
        
        await token.transfer(staking.address, 50, "Sent", {from: accounts[1], gas: 1000000});

    });

    it("Users can tip staked tokens (maximum 10 SPN per tip)", async function() {

        await assertFail(async function() {
            await staking.tipUser(accounts[2], 11, {from: accounts[1]});
        });

        await staking.tipUser(accounts[2], 10, {from: accounts[1]});

        assert.equal(await staking.balanceOf(accounts[2]), 10);

    });

    it("Interact with Sapien", async function() {
        
        await staking.changeActionCost("COMMENT",1, {from: accounts[0]});

        await staking.changeActionCost("VOTE",5, {from: accounts[0]});

        await staking.changeActionCost("POST",10, {from: accounts[0]});

        await staking.interactWithSapien("COMMENT", {from: accounts[1]});

        await staking.interactWithSapien("VOTE", {from: accounts[1]});

        await staking.interactWithSapien("POST", {from: accounts[1]});

        assert.equal(await staking.balanceOf(accounts[1]), 34);
        
    });

});