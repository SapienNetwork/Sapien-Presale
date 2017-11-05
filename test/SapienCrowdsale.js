let SapienCrowdsale = artifacts.require('./SapienCrowdsale.sol');
let SapienCoin = artifacts.require('./SapienCoin.sol');
let MultisigWallet = artifacts.require('./MultisigWallet.sol');

const assertFail = require("./helpers/assertFail");
const updateController = require("./helpers/updateController");

contract('SapienCrowdsale', function(accounts) {

    const startBlock = web3.eth.blockNumber + 300;
    const endBlock = startBlock + 300;
    const rate = new web3.BigNumber(2500);
    const cap = new web3.BigNumber(73000000000000000000000); //73k ether hardcap

    let SPN, wallet;

    beforeEach(async () => {
        SPN = await SapienCoin.new();
        wallet = await MultisigWallet.new([accounts[0], accounts[1], accounts[2]]);
    });
    
    it("Deploys contract with correct hardcap", async function() {
        let crowdsale = await SapienCrowdsale.new({ from: accounts[0] });
        await crowdsale.initialize(startBlock, endBlock, rate, wallet.address, cap, SPN.address, {from: accounts[0], gas: 900000});
        await updateController(SPN, crowdsale.address);
        let hardcap = await crowdsale.weiCap.call();
        assert.equal(hardcap.toString(), cap.toString(), "Deployed hardcap is not equal to hardcap");
    });

    it("Checks that nobody can buy before the crowdsale begins", async function() {
        let crowdsale = await SapienCrowdsale.new({ from: accounts[0] });
        await crowdsale.initialize(startBlock, endBlock, rate, wallet.address, cap, SPN.address, {from: accounts[0], gas: 900000});
        await updateController(SPN, crowdsale.address);
        await assertFail(async function() {
            await crowdsale.buyTokens(accounts[1], { value: web3.toWei(1), from: accounts[1] });
        });
    });

    it("Checks that only owner can pause campaign", async function() {
        let crowdsale = await SapienCrowdsale.new({ from: accounts[0] });
        await crowdsale.initialize(web3.eth.blockNumber + 1, endBlock, rate, wallet.address, cap, SPN.address, {from: accounts[0], gas: 900000});
        await updateController(SPN, crowdsale.address);
        await assertFail(async function() {
            await crowdsale.pauseContribution({ from: accounts[1] });
        });

        await crowdsale.pauseContribution({ from: accounts[0] });
    });

    it("Checks that nobody can buy if the crowdsale is paused", async function() {
        let crowdsale = await SapienCrowdsale.new({ from: accounts[0] });
        await crowdsale.initialize(web3.eth.blockNumber + 1, endBlock, rate, wallet.address, cap, SPN.address, {from: accounts[0], gas: 900000});
        await updateController(SPN, crowdsale.address);
        await crowdsale.pauseContribution();
        await assertFail(async function() {
            await crowdsale.buyTokens(accounts[1], { value: web3.toWei(1), from: accounts[1] });
        });
    });

    it("Checks that anyone can buy tokens after crowdsale has started", async function() {
        let crowdsale = await SapienCrowdsale.new({ from: accounts[0] });
        await crowdsale.initialize(web3.eth.blockNumber + 1, endBlock, rate, wallet.address, cap, SPN.address, {from: accounts[0], gas: 900000});
        await updateController(SPN, crowdsale.address);
        await crowdsale.buyTokens(accounts[1], { value: web3.toWei(1), from: accounts[1] });
    });

    it("Checks if we computed the bonus correctly", async function() {

        let bonusRate = rate;

        let weiAmount = 1000 * 10**18;

        if (weiAmount >= 33 * 10**18 && weiAmount < 166 * 10**18) {
            
                bonusRate = 2575;
            
        } else if (weiAmount >= 166 * 10**18 && weiAmount < 333 * 10**18) {
            
                bonusRate = 2675;
            
        } else if (weiAmount >= 333 * 10**18 && weiAmount < 833 * 10**18) {
            
                bonusRate = 2875;
            
        } else if (weiAmount >= 833 * 10**18 && weiAmount < 1666 * 10**18) {
            
                bonusRate = 3000;
            
        } else if (weiAmount >= 1666 * 10**18) {
            
                bonusRate = 3750;
            
        }

        let tokens = weiAmount * bonusRate;

        assert.equal(tokens, 3000 * 1000 * 10**18);

    });

    it("Checks that gas prices over 50Gwei are rejected", async function() {
        let crowdsale = await SapienCrowdsale.new({ from: accounts[0] });
        await crowdsale.initialize(web3.eth.blockNumber + 1, endBlock, rate, wallet.address, cap, SPN.address, {from: accounts[0], gas: 900000});
        await updateController(SPN, crowdsale.address);
        await crowdsale.resumeContribution({ from: accounts[0] }); //waste one block
        await assertFail(async function() {
            await crowdsale.buyTokens(accounts[1], { value: 1000, from: accounts[1], gasPrice: '50000000001'});
        });

    });

    it("Checks crowdsale is over once hardcap is reached", async function() {
        let crowdsale = await SapienCrowdsale.new({ from: accounts[0] });
        await crowdsale.initialize(web3.eth.blockNumber + 1, endBlock, rate, wallet.address, cap, SPN.address, {from: accounts[0], gas: 900000});
        await updateController(SPN, crowdsale.address);
        await crowdsale.buyTokens(accounts[2], { value: cap, from: accounts[2] });

        await assertFail(async function() {
            await crowdsale.buyTokens(accounts[1], { value: web3.toWei(1), from: accounts[1] });
        });

    });

    it("Checks that contributed ethereum is forwarded to wallet", async function() {
        let crowdsale = await SapienCrowdsale.new({ from: accounts[0] });
        await crowdsale.initialize(web3.eth.blockNumber + 1, endBlock, rate, wallet.address, cap, SPN.address, {from: accounts[0], gas: 900000});
        await updateController(SPN, crowdsale.address);

        let contributingAmount = parseInt(web3.toWei(1000, 'ether'));
        let walletBalanceBefore = await web3.eth.getBalance(wallet.address).toNumber();
        await crowdsale.buyTokens(accounts[2], { value: contributingAmount, from: accounts[2] });
        await crowdsale.safeWithdrawal({ from: accounts[0] });
        let walletBalanceAfter = await web3.eth.getBalance(wallet.address).toNumber();

        assert.equal(walletBalanceAfter, walletBalanceBefore + contributingAmount, "Balance contributed is not equal to wallet balance");

    });
});
