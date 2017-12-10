let SapienCrowdsale = artifacts.require('./SapienCrowdsale.sol');
let SapienToken = artifacts.require('contracts/SapienToken.sol');
let MultisigWallet = artifacts.require('./MultisigWallet.sol');
let TokenController = artifacts.require('./TokenController.sol');
let Owned = artifacts.require('./Owned');
let CrowdsaleStorage = artifacts.require('contracts/storage/CrowdsaleStorage.sol');

const assertFail = require("./helpers/assertFail");
const updateController = require("./helpers/updateController");

contract('SapienCrowdsale', function(accounts) {

    const startBlock = web3.eth.blockNumber + 10;
    const endBlock = startBlock + 300;
    const rate = new web3.BigNumber(4000);
    const cap = new web3.BigNumber(73000000000000000000000); //73k ether hardcap

    let Controller, wallet, _storage, crowdsale;

    beforeEach(async () => {
        Controller = await TokenController.new(SapienToken.address, Owned.address);
        wallet = await MultisigWallet.new([accounts[0], accounts[1], accounts[2]], 2);
        _storage = await CrowdsaleStorage.new(Owned.address, {from: accounts[0]});
        crowdsale = await SapienCrowdsale.new(Owned.address, { from: accounts[0] });

        await _storage.addContract(crowdsale.address, {from: accounts[0]});

        await crowdsale.changeCrowdsaleStorage(_storage.address, {from: accounts[0]});

        await crowdsale.changeBonusMilestone(0, 33, {from: accounts[0]});
        await crowdsale.changeBonusMilestone(1, 166, {from: accounts[0]});
        await crowdsale.changeBonusMilestone(2, 350, {from: accounts[0]});
        await crowdsale.changeBonusMilestone(3, 600, {from: accounts[0]});
        await crowdsale.changeBonusMilestone(4, 800, {from: accounts[0]});

        await crowdsale.changeBonusRate(0, 4300, {from: accounts[0]});
        await crowdsale.changeBonusRate(1, 4700, {from: accounts[0]});
        await crowdsale.changeBonusRate(2, 5500, {from: accounts[0]});
        await crowdsale.changeBonusRate(3, 6100, {from: accounts[0]});
        await crowdsale.changeBonusRate(4, 7000, {from: accounts[0]});

    });
    
    it("Deploys contract with correct hardcap", async function() {
        await crowdsale.initialize(startBlock, endBlock, rate, wallet.address, cap, Controller.address, _storage.address, {from: accounts[0], gas: 900000});
        let hardcap = await crowdsale.weiCap.call();
        assert.equal(hardcap.toString(), cap.toString(), "Deployed hardcap is not equal to hardcap");
    });

    it("Checks that nobody can buy before the crowdsale begins", async function() {
        await crowdsale.initialize(startBlock, endBlock, rate, wallet.address, cap, Controller.address, _storage.address, {from: accounts[0], gas: 900000});
       
        await assertFail(async function() {
            await crowdsale.buyTokens(accounts[1], { value: web3.toWei(0.5), from: accounts[1] });
        });
    });

    it("Checks that only owner can pause campaign", async function() {
        await crowdsale.initialize(web3.eth.blockNumber, endBlock, rate, wallet.address, cap, Controller.address, _storage.address, {from: accounts[0], gas: 900000});
       
        await assertFail(async function() {
            await crowdsale.pauseContribution({ from: accounts[1] });
        });

        await crowdsale.pauseContribution({ from: accounts[0] });

        assert.equal(crowdsale.paused.call(), true);

    });

    it("Checks that nobody can buy if the crowdsale is paused", async function() {
        await crowdsale.initialize(web3.eth.blockNumber, endBlock, rate, wallet.address, cap, Controller.address, _storage.address, {from: accounts[0], gas: 900000});
    
        await crowdsale.pauseContribution();
        await assertFail(async function() {
            await crowdsale.buyTokens(accounts[1], { value: web3.toWei(0.5), from: accounts[1] });
        });
    });

    it("Checks that anyone can buy tokens after crowdsale has started", async function() {
        await crowdsale.initialize(web3.eth.blockNumber, endBlock, rate, wallet.address, cap, Controller.address, _storage.address, {from: accounts[0], gas: 900000});
       
        await crowdsale.buyTokens(accounts[1], { value: web3.toWei(0.5), from: accounts[1] });

        let boughtTokens = _storage.getInvestorTokens(accounts[1], {from: accounts[1]});

        assert.equal(boughtTokens, 2000);
    });

    //NEED TO MAKE getBonusRate PUBLIC TO PASS TEST

   /* it("Checks if we computed the bonus correctly", async function() {

        await crowdsale.initialize(web3.eth.blockNumber, endBlock, rate, wallet.address, cap, Controller.address, _storage.address, {from: accounts[0], gas: 900000});
        
        let bonus = await crowdsale.getBonusRate(1000000000000000000);

        assert.equal(4000, bonus);

        bonus = await crowdsale.getBonusRate(40 * 10 ** 18);

        assert.equal(4300, bonus);

        bonus = await crowdsale.getBonusRate(170 * 10 ** 18);

        assert.equal(4700, bonus);

        bonus = await crowdsale.getBonusRate(360 * 10 ** 18);
        
        assert.equal(5500, bonus);

        bonus = await crowdsale.getBonusRate(700 * 10 ** 18);
                
        assert.equal(6100, bonus);

        bonus = await crowdsale.getBonusRate(900 * 10 ** 18);
        
        assert.equal(7000, bonus);

    }); */

    it("Checks that gas prices over 500K wei are rejected", async function() {
        await crowdsale.initialize(web3.eth.blockNumber, endBlock, rate, wallet.address, cap, Controller.address, _storage.address, {from: accounts[0], gas: 900000});
    
        await crowdsale.resumeContribution({ from: accounts[0] }); //waste one block
        await assertFail(async function() {
            await crowdsale.buyTokens(accounts[1], { value: 1000, from: accounts[1], gasPrice: '500009'});
        });

    });

    it("Checks crowdsale is over once hardcap is reached", async function() {
        await crowdsale.initialize(web3.eth.blockNumber, endBlock, rate, wallet.address, cap, Controller.address, _storage.address, {from: accounts[0], gas: 900000});
        
        await crowdsale.buyTokens(accounts[2], { value: cap, from: accounts[2] });

        await assertFail(async function() {
            await crowdsale.buyTokens(accounts[1], { value: web3.toWei(0.5), from: accounts[1] });
        });

    });

    it("Checks that contributed ether is forwarded to wallet", async function() {
        await crowdsale.initialize(web3.eth.blockNumber, web3.eth.blockNumber + 1, rate, wallet.address, cap, Controller.address, _storage.address, {from: accounts[0], gas: 900000});

        let contributingAmount = parseInt(web3.toWei(1000, 'ether'));

        await crowdsale.buyTokens(accounts[2], { value: contributingAmount, from: accounts[2] });
        let walletBalanceBefore = await web3.eth.getBalance(wallet.address).toNumber();
        
        await crowdsale.safeWithdrawal({ from: accounts[0] });
        let walletBalanceAfter = await web3.eth.getBalance(wallet.address).toNumber();

        assert.equal(walletBalanceAfter, walletBalanceBefore + contributingAmount, "Balance contributed is not equal to wallet balance");

    });
});
