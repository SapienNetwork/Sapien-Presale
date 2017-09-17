let SapienCrowdSale = artifacts.require('./SapienCrowdSale.sol');

const assertFail = require("./helpers/assertFail");

contract('SapienCrowdSale', function(accounts) {

    const _startBlock = web3.eth.blockNumber + 300;
    const _endBlock = _startBlock + 300;
    const _rate = new web3.BigNumber(1000);
    const _wallet = web3.eth.accounts[0];
    const _cap = new web3.BigNumber(83000000000000000000000); //83k ether hardcap

    it("Deploys contract with correct hardcap", async function() {
        let crowdsale = await SapienCrowdSale.new(_startBlock, _endBlock, _rate, _wallet, _cap, { from: accounts[0] });
        let hardcap = await crowdsale.cap.call();
        assert.equal(hardcap.toString(), _cap.toString(), "Deployed hardcap is not equal to hardcap");
    });

    it("Checks that nobody can buy before the crowdsale begins", async function() {
        let crowdsale = await SapienCrowdSale.new(_startBlock, _endBlock, _rate, _wallet, _cap, { from: accounts[0] });
        await assertFail(async function() {
            await crowdsale.buyTokens(accounts[1], { value: web3.toWei(1), from: accounts[1] });
        });
    });

});
