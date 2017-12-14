let SapienCrowdsale = artifacts.require('contracts/SapienCrowdsale.sol');
let SapienToken = artifacts.require('contracts/SapienToken.sol');
let MultisigWallet = artifacts.require('contracts/MultisigWallet.sol');
let TokenController = artifacts.require('contracts/TokenController.sol');
let Owned = artifacts.require('contracts/Owned');
let CrowdsaleStorage = artifacts.require('contracts/storage/CrowdsaleStorage.sol');

const assertFail = require("./helpers/assertFail");

contract('SapienCrowdsale', function(accounts) {

    const startBlock = web3.eth.blockNumber + 100;
    const endBlock = startBlock + 300;
    const rate = new web3.BigNumber(4000);
    const cap = new web3.BigNumber(2300000000000000000000); //2300 ether hardcap

    const tokenAmount = 30 * 10 ** 18;

    let Controller;
    let wallet;
    let _storage;
    let crowdsale;
    let owned;
    let sapienToken;

    beforeEach(async () => {
        
        owned = await Owned.new({from: accounts[0]});
        sapienToken = await SapienToken.new(owned.address, tokenAmount, {from: accounts[0]});
        
        Controller = await TokenController.new(sapienToken.address, owned.address, {from: accounts[0]});
        wallet = await MultisigWallet.new([accounts[0], accounts[1], accounts[2]], 2, {from: accounts[0]});
        _storage = await CrowdsaleStorage.new(owned.address, {from: accounts[0]});
        crowdsale = await SapienCrowdsale.new(owned.address, { from: accounts[0] });

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

        await _storage.addContract(crowdsale.address, {from: accounts[0]});

    });
    
    it("Deploys contract with correct hardcap", async function() {
        
        await crowdsale.initialize(1, 2, rate, wallet.address, cap, Controller.address, _storage.address, {from: accounts[0]});
        const hardcap = await crowdsale.weiCap.call();
        assert.equal(hardcap.toString(), cap.toString(), "Deployed hardcap is not equal to hardcap");

    });

    // Need requires in the initialize function to be uncommented

    it("Checks that nobody can buy before the crowdsale begins", async function() {
        await crowdsale.initialize(1, 2, rate, wallet.address, cap, Controller.address, _storage.address, {from: accounts[0]});
       
        await assertFail(async function() {
            await crowdsale.buyTokens({ value: web3.toWei(0.5), from: accounts[1] });
        });
    });

    it("Checks that only owner can pause campaign", async function() {
        await crowdsale.initialize(1, 2, rate, wallet.address, cap, Controller.address, _storage.address, {from: accounts[0]});
       
        await assertFail(async function() {
            await crowdsale.pauseContribution({ from: accounts[1] });
        });

        await crowdsale.pauseContribution({ from: accounts[0] });

        assert.equal(await crowdsale.paused.call(), true);

    });

    // Need requires in the initialize function to be uncommented

    it("Checks that nobody can buy if the crowdsale is paused", async function() {
        await crowdsale.initialize(1, 2, rate, wallet.address, cap, Controller.address, _storage.address, {from: accounts[0], gas: 900000});
    
        await crowdsale.pauseContribution({from: accounts[0]});
        await assertFail(async function() {
            await crowdsale.buyTokens({ value: web3.toWei(0.5), from: accounts[1] });
        });
    });

    //Comment all requires from buyTokens in SapienCrowdsale for this test
    //Comment the modifiers from buyTokens
    //Comment require(validPurchase(msg.sender, allowed)); from buyTokens

    it("Checks that anyone can buy tokens after crowdsale has started", async function() {

        await crowdsale.initialize(0, 2, rate, wallet.address, cap, Controller.address, _storage.address, {from: accounts[0], gas: 900000});

        await crowdsale.buyTokens({ value: web3.toWei(1), from: accounts[1] });

        let boughtTokens = await _storage.getInvestorTokens(accounts[1], {from: accounts[1]});

        assertFail.equal(4000, boughtTokens)

    });

    //Comment all requires from buyTokens in SapienCrowdsale for this test
    //Comment the modifiers from buyTokens
    //Comment require(validPurchase(msg.sender, allowed)); from buyTokens

    it("Checks that investors can get a refund", async function() {
        
        await crowdsale.initialize(0, 1, rate, wallet.address, cap, Controller.address, _storage.address, {from: accounts[0], gas: 900000});
       
        await crowdsale.buyTokens({ value: web3.toWei(1), from: accounts[1] });

        let investment = await _storage.getInvestorWei(accounts[1], {from: accounts[0]});

        await crowdsale.refundInvestment(investment, {from: accounts[1]});

        investment = await _storage.getInvestorTokens(accounts[1], {from: accounts[0]});        

        assert.equal(investment, 0);

    });

    
    it("Checks if we computed the bonus correctly", async function() {

        await crowdsale.initialize(0, 1, rate, wallet.address, cap, Controller.address, _storage.address, {from: accounts[0], gas: 900000});
        
        let bonus = await crowdsale.getBonusRate(web3.toWei(0.5));

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

    }); 

    //Need the validGasPrice for this

    it("Checks that gas prices over 2M wei are rejected", async function() {
        await crowdsale.initialize(0, 2, rate, wallet.address, cap, Controller.address, _storage.address, {from: accounts[0], gas: 900000});
    
        await crowdsale.resumeContribution({ from: accounts[0] }); //waste one block
        await assertFail(async function() {
            await crowdsale.buyTokens({ value: 1000, from: accounts[1], gas: 2000001});
        });

    });

    it("Checks crowdsale is over once hardcap is reached", async function() {
        await crowdsale.initialize(0, 2, rate, wallet.address, cap, Controller.address, _storage.address, {from: accounts[0], gas: 900000});
        
        await crowdsale.buyTokens({ value: cap, from: accounts[2] });

        await assertFail(async function() {
            await crowdsale.buyTokens({ value: web3.toWei(0.5), from: accounts[1] });
        });

    });

    it("Checks that investors can't claim tokens before the end", async function() {
        await crowdsale.initialize(0, 10, rate, wallet.address, cap, Controller.address, _storage.address, {from: accounts[0], gas: 900000});
        
        await assertFail(async function() {
            await crowdsale.claimTokens({from: accounts[1]});
        });

    });

    //Comment the validGasPrice modifier from buy for this test

    it("Checks that contributed ether is forwarded to wallet", async function() {
        await crowdsale.initialize(0, 0, rate, wallet.address, cap, Controller.address, _storage.address, {from: accounts[0], gas: 900000});

        let amountInvested = web3.toWei(0.5);

        await crowdsale.buyTokens({ value: amountInvested, from: accounts[2] });
        
        let walletBalanceBefore = await web3.eth.getBalance(wallet.address).toNumber();
        
        await crowdsale.safeWithdrawal({ from: accounts[0] });
        let walletBalanceAfter = await web3.eth.getBalance(wallet.address).toNumber();

        assert.equal(walletBalanceBefore + amountInvested, walletBalanceAfter, "Balance contributed is not equal to wallet balance");

    });

    it("Checks that escape hatch blocks all necessary functions", async function() {

        await assertFail(async function() {
            await crowdsale.escapeHatch({from: accounts[1]});
        });

        await crowdsale.escapeHatch({from: accounts[0]});

        await assertFail(async function() {
            await crowdsale.buyTokens({from: accounts[1]});
        });

        await assertFail(async function() {
            await crowdsale.initialize(0, 1, rate, wallet.address, cap, Controller.address, _storage.address, {from: accounts[0], gas: 900000});            
        });

        await assertFail(async function() {
            await crowdsale.changeBonusMilestone(0, 1000, {from: accounts[0]});
        });

        await assertFail(async function() {
            await crowdsale.changeBonusRate(0, 1000, {from: accounts[0]});
        });

        await assertFail(async function() {
            await crowdsale.changeDynamic('0x0', {from: accounts[0]});
        });

        await assertFail(async function() {
            await crowdsale.changeCrowdsaleStorage('0x0', {from: accounts[0]});
        });

        await assertFail(async function() {
            await crowdsale.switchTokenController('0x0', {from: accounts[0]});
        });

        await assertFail(async function() {
            await crowdsale.switchWallet('0x0', {from: accounts[0]});
        });

        await assertFail(async function() {
            await crowdsale.limitPerInvestor(10**18, {from: accounts[0]});
        });

        await assertFail(async function() {
            await crowdsale.changeBaseRate(5000, {from: accounts[0]});
        });

        await assertFail(async function() {
            await crowdsale.buyTokens(5000, {from: accounts[0]});
        });

    });

});
