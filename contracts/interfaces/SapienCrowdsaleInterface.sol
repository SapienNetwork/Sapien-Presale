pragma solidity ^0.4.18;

contract SapienCrowdsaleInterface {

    // maximum gas price for contribution transactions
    uint256 public constant MAX_GAS_PRICE = 50000000000;

    // start and end block where investments are allowed (both inclusive)
    uint256 public startBlock;
    uint256 public endBlock;

    // how many token units a buyer gets per wei
    uint256 public rate;

    // amount of raised money in wei
    uint256 public weiRaised;

    // hard cap, campaign ends after reached
    uint256 public weiCap;

    //for escape hatch; if 0, all functions can be used; if 1, only some functions can be used
    uint256 private blockAttack = 0; 

    //how much Ether an investor can actually invest in the crowdsale; if 0, any investor can send as much Ether as they want
    uint256 investorLimit = 0;
    
    // address where funds are collected
    address private wallet;

     //allows for owner to pause the campaign if needed
    bool public paused;

    //investment milestones for participants in the crowdsale 
    //(ex: 33 eth, 100 eth, 500 eth, 1000 eth and 2000 eth)
    //used to determine bonuses

    mapping(uint256 => uint256) public bonusMilestones;
    mapping(uint256 => uint256) public bonusRates;

    struct Investor {

        uint256 amountOfWeiInvested;
        uint256 calculatedTokens;

    }

    mapping(address => Investor) public investorInfo;

     /**
     * event for token purchase logging
     * @param purchaser who paid for the tokens
     * @param beneficiary who got the tokens
     * @param value weis paid for purchase
     * @param amount amount of tokens purchased
     */
    event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);

    event Transferred(uint256 amount);

    function changeOwned(address _owned) public;

    function initialize(uint256 _startBlock, uint256 _endBlock, uint256 _rate, address _wallet, uint256 _cap, address _token) public;

    function changeBonusMilestone(uint256 position, uint256 newValue) public;

    function changeBonusRate(uint256 position, uint256 newValue) public;

    function changeDynamic(address _dynamic) public;

    function pauseContribution() public;

    function resumeContribution();

    function switchSapienToken(address _token);

    function switchWallet(address _wallet);

    function limitPerInvestor(uint256 limit) public;

    function changeBaseRate(uint256 baseRate);

    function buyTokens(address beneficiary) payable;

    function getBonusRate(uint256 weiAmount) internal returns (uint256);

    function refundInvestment(uint256 weiAmount) public;

    function safeWithdrawal() public;

    function distributeTokens(address investor) public;

    function claimTokens() public;

    function validPurchase(address investor, uint256 allowed) internal constant returns (bool);

    function isContract(address _addr) internal constant returns (bool is_contract);

    function escapeHatch() public;

}