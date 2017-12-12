let TokenController = artifacts.require('contracts/TokenController.sol');
let Owned = artifacts.require('contracts/Owned.sol');
let SapienToken = artifacts.require('contracts/SapienToken.sol');

contract('TokenController', function(accounts) {

    it("SapienToken deployed with SPN symbol", async function() {
        let SPN = await SapienToken.new(TokenController.address, Owned.address);
        let symbol = await SPN.symbol.call();

        assert.equal(symbol, 'SPN', 'Symbol name is not SPN');
    });

    it("Checks that SPN's Controller is transferable", async function() {
        let SPN = await SapienToken.new(TokenController.address, Owned.address);
        await SPN.changeController(TokenController.address);
        const controller = await SPN.controller.call();

        assert.equal(controller, TokenController.address);

    });

    it("Checks that SPN is mintable", async function() {
        let SPN = await SapienToken.new(TokenController.address, Owned.address);
        let totalSupply = await SPN.totalSupply.call();
        assert.equal(totalSupply, 0, "Initial total supply is not 0.");
        let toMint = 100;

        let controller = await TokenController.new(Owned.address);

        await controller.mint(accounts[1], toMint);

        totalSupply = await SPN.totalSupply.call();
        assert.equal(totalSupply, toMint, `Total supply is not ${toMint}`);

        let accountBalance = await SPN.balanceOf(accounts[1]);
        assert.equal(accountBalance, toMint, `Account balance is not ${toMint}`);
    });

});
