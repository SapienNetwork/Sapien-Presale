pragma solidity ^0.4.18;

/// @author Stefan Ionescu - <codrinionescu@yahoo.com>

contract SapienCrowdsaleInterface {

     /**
     * event for token purchase logging
     * @param purchaser who paid for the tokens
     * @param value weis paid for purchase
     * @param amount amount of tokens purchased
     */
    event TokenPurchase(address indexed purchaser, uint256 value, uint256 amount);

    /**
    * @dev Triggered when we want to withdraw funds to wallet
    */
    event TransferredToWallet(uint256 amount);

    /**
    * Called when investor tokens are allocated
    */
    event AllocateTokens(address sender, address who, uint256 amount);

    //Changing the owner of the contract
    function changeOwned(address _owned) public;

    //Initialize a new crowdsale
    function initialize(uint256 hoursUntilStart, uint256 hoursUntilEnd, uint256 _rate, address _wallet, uint256 _cap, address _token, address _storageAddress) public;

    //Change a certain milestone bonus
    function changeBonusMilestone(uint256 position, uint256 newValue) public;

    function changeBonusRate(uint256 position, uint256 newValue) public;

    //Change the dynamic contract which puts limits for whales
    function changeDynamic(address _dynamic) public;

    //Change crowdsale's storage contract
    function changeCrowdsaleStorage(address _storageAddress) public;

    //Pause campaign in case of bug/attack/anything else
    function pauseContribution() public;

    //Resume campaign
    function resumeContribution() public;

    //Change the token controller that allocates the preminted SPN
    function switchTokenController(address _token) public;

    //Change the wallet where we send the funds from investors
    function switchWallet(address _wallet) public;

    //Ether limit per investor; need KYC for each investor to make sure we can limit them
    function limitPerInvestor(uint256 limit) public;

    //Change how many SPN we offer for investments of under $10K
    function changeBaseRate(uint256 baseRate) public;

    //Change max gas price allowed for buyTokens
    function changeMaximumGasLimit(uint256 gasLimit) public;

    //How much can an investor invest in the crowdsale at this moment?
    function computeAllowedInvestment(uint256 investment) public constant returns (uint256);

    //Used by investors to buy tokens
    function buyTokens() public payable;

    //How much bonus does one investor get for the ether sent
    function getBonusRate(uint256 weiAmount) public constant returns (uint256);

    //Called by investors when they want to withdraw their investment; can be used before crowdsale ends
    function refundInvestment(uint256 weiAmount) public;

    //Withdrawing the ether gathered in a wallet after the campaign ends
    function safeWithdrawal() public;

    //Used by owner to distribute tokens to investors in case someone forgets to take their tokens
    function distributeTokens(address investor) public;

    //Used by investors to get their tokens after campaign ends
    function claimTokens() public;

    //Check if investor is qualified to invest
    function validPurchase(address investor, uint256 allowed) internal returns (bool);

    //Check if investor is a contract; if it is a contract, we will block them
    function isContract(address _addr) internal constant returns (bool is_contract);

    //Block the majority of functions from being called in case of attack/vulnerability/etc
    function escapeHatch() public;

}