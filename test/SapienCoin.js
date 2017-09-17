var SapienCoin = artifacts.require('./SapienCoin.sol');

contract('SapienCrowdSale', function(accounts) {

    it("SapienCoin deployed with SPN symbol", async function() {
        let SPN = await SapienCoin.deployed();
        let symbol = await SPN.symbol.call();
        assert.equal(symbol, 'SPN', 'Symbol name is not SPN');
    });

});
