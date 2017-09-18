let SapienCoin = artifacts.require('./SapienCoin.sol');

contract('SapienCoin', function(accounts) {

    it("SapienCoin deployed with SPN symbol", async function() {
        let SPN = await SapienCoin.new();
        let symbol = await SPN.symbol.call();
        assert.equal(symbol, 'SPN', 'Symbol name is not SPN');
    });

    it("Checks that SPN's Controller is transferable", async function() {
        let SPN = await SapienCoin.new();
        await SPN.changeController(accounts[1]);
        const controller = await SPN.controller.call();

        assert.equal(controller, accounts[1]);
    });

    it("Checks that SPN is mintable", async function() {
        let SPN = await SapienCoin.new();
        let totalSupply = await SPN.totalSupply.call();
        assert.equal(totalSupply, 0, "Initial total supply is not 0.");
        let toMint = 100;

        await SPN.mint(accounts[1], toMint);

        totalSupply = await SPN.totalSupply.call();
        assert.equal(totalSupply, toMint, `Total supply is not ${toMint}`);

        let accountBalance = await SPN.balanceOf(accounts[1]);
        assert.equal(accountBalance, toMint, `Account balance is not ${toMint}`);
    });

});
