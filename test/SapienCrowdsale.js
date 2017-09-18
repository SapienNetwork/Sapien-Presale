let SapienCrowdSale = artifacts.require('./SapienCrowdSale.sol');
let SapienCoin = artifacts.require('./SapienCoin.sol');

const assertFail = require("./helpers/assertFail");
const updateController = require("./helpers/updateController");

contract('SapienCrowdSale', function(accounts) {

    const startBlock = web3.eth.blockNumber + 300;
    const endBlock = startBlock + 300;
    const rate = new web3.BigNumber(1000);
    const wallet = web3.eth.accounts[0];
    const cap = new web3.BigNumber(83000000000000000000000); //83k ether hardcap

    let SPN;

    beforeEach(async () => {
        SPN = await SapienCoin.new();
    });


    it("Deploys contract with correct hardcap", async function() {
        let crowdsale = await SapienCrowdSale.new({ from: accounts[0] });
        await crowdsale.initalize(startBlock, endBlock, rate, wallet, cap, SPN.address, {from: accounts[0], gas: 900000});
        await updateController(SPN, crowdsale.address);
        let hardcap = await crowdsale.cap.call();
        assert.equal(hardcap.toString(), cap.toString(), "Deployed hardcap is not equal to hardcap");
    });

    it("Checks that nobody can buy before the crowdsale begins", async function() {
        let crowdsale = await SapienCrowdSale.new({ from: accounts[0] });
        await crowdsale.initalize(startBlock, endBlock, rate, wallet, cap, SPN.address, {from: accounts[0], gas: 900000});
        await updateController(SPN, crowdsale.address);
        await assertFail(async function() {
            await crowdsale.buyTokens(accounts[1], { value: web3.toWei(1), from: accounts[1] });
        });
    });

    it("Checks that only owner can pause campaign", async function() {
        let crowdsale = await SapienCrowdSale.new({ from: accounts[0] });
        await crowdsale.initalize(web3.eth.blockNumber + 1, endBlock, rate, wallet, cap, SPN.address, {from: accounts[0], gas: 900000});
        await updateController(SPN, crowdsale.address);
        await assertFail(async function() {
            await crowdsale.pauseContribution({ from: accounts[1] });
        });

        await crowdsale.pauseContribution({ from: accounts[0] });
    });

    it("Checks that nobody can buy if the crowdsale is paused", async function() {
        let crowdsale = await SapienCrowdSale.new({ from: accounts[0] });
        await crowdsale.initalize(web3.eth.blockNumber + 1, endBlock, rate, wallet, cap, SPN.address, {from: accounts[0], gas: 900000});
        await updateController(SPN, crowdsale.address);
        await crowdsale.pauseContribution();
        await assertFail(async function() {
            await crowdsale.buyTokens(accounts[1], { value: web3.toWei(1), from: accounts[1] });
        });
    });

    it("Checks that anyone can buy tokens after crowdsale has started", async function() {
        let crowdsale = await SapienCrowdSale.new({ from: accounts[0] });
        await crowdsale.initalize(web3.eth.blockNumber + 1, endBlock, rate, wallet, cap, SPN.address, {from: accounts[0], gas: 900000});
        await updateController(SPN, crowdsale.address);
        await crowdsale.resumeContribution({ from: accounts[0] }); //waste one block
        await crowdsale.buyTokens(accounts[1], { value: 1, from: accounts[1] });
    });


});
