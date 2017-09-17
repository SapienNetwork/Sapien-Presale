let SapienCrowdSale = artifacts.require('./SapienCrowdSale.sol');
let SapienCoin = artifacts.require('./SapienCoin.sol');

const assertFail = require("./helpers/assertFail");

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
        crowdsale.initalize(startBlock, endBlock, rate, wallet, cap, SPN.address, {from: accounts[0], gas: 900000});
        let hardcap = await crowdsale.cap.call();
        assert.equal(hardcap.toString(), cap.toString(), "Deployed hardcap is not equal to hardcap");
    });

    it("Checks that nobody can buy before the crowdsale begins", async function() {
        let crowdsale = await SapienCrowdSale.new({ from: accounts[0] });
        crowdsale.initalize(startBlock, endBlock, rate, wallet, cap, SPN.address, {from: accounts[0], gas: 900000});

        await assertFail(async function() {
            await crowdsale.buyTokens(accounts[1], { value: web3.toWei(1), from: accounts[1] });
        });
    });

});
