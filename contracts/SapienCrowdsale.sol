pragma solidity ^0.4.15;

import "contracts/Owned.sol";
import "contracts/TokenController.sol";
import "node_modules/zeppelin-solidity/contracts/math/SafeMath.sol";

contract SapienCrowdsale {

    using SafeMath for uint256;

    // maximum gas price for contribution transactions
    uint256 public constant MAX_GAS_PRICE = 50000000000;

    // start and end block where investments are allowed (both inclusive)
    uint256 public startBlock;
    uint256 public endBlock;

    // address where funds are collected
    address public wallet;

    // how many token units a buyer gets per wei
    uint256 public rate;

    // amount of raised money in wei
    uint256 public weiRaised;

    // hard cap, campaign ends after reached
    uint256 public weiCap;

    //SPN token
    TokenController public token;

    //allows for owner to pause the campaign if needed
    bool public paused;

    Owned private owned;

    struct Investor {

        uint256 amountOfWeiInvested;
        uint256 calculatedTokens;

    }

    mapping(address => Investor) public investorWei;

    modifier afterDeadline() {

        require(block.number >= endBlock);
         _;

    }

    modifier notPaused() {
        require(!paused);
        _;
    }

    modifier refundCondition() {

        require(block.number < endBlock);
        _;

    }

    // verifies that gas price is below max gas price (prevents "cutting in line")
    modifier validGasPrice() {
        require(tx.gasprice <= MAX_GAS_PRICE);
        _;
    }

    /// @dev `owner` is the only address that can call a function with this
    /// modifier
    modifier onlyOwner() {
        require(msg.sender == owned.getOwner());
        _;
    }

    function SapienCrowdsale(address _owned) {
        paused = false;
        owned = Owned(_owned);
    }

     function changeOwned(address _owned) onlyOwner {

        owned = Owned(_owned);

    }

    function initialize(uint256 _startBlock, uint256 _endBlock, uint256 _rate, address _wallet, uint256 _cap, address _token) onlyOwner {

        require(_startBlock >= block.number);
        require(_endBlock >= _startBlock);
        require(_rate > 0);
        require(_wallet != 0x0);
        require(_cap > 0);
        require(_token != 0x0);

        startBlock = _startBlock;
        endBlock = _endBlock;
        rate = _rate;
        wallet = _wallet;
        weiCap = _cap;
        token = TokenController(_token);

    }

    // Pauses the contribution if there is any issue
    function pauseContribution() onlyOwner {
        paused = true;
    }

    // Resumes the contribution
    function resumeContribution() onlyOwner {
        paused = false;
    }

    function switchSapienToken(address _token) onlyOwner {

        token = TokenController(_token);

    }

    /**
     * event for token purchase logging
     * @param purchaser who paid for the tokens
     * @param beneficiary who got the tokens
     * @param value weis paid for purchase
     * @param amount amount of tokens purchased
     */
    event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);

    event Transferred(uint256 amount);

    // fallback function can be used to buy tokens
    function () payable {
        buyTokens(msg.sender);
    }

    function buyTokens(address beneficiary) payable validGasPrice {
        
        require(beneficiary != 0x0);
        require(validPurchase());

        uint256 bonusRate = getBonusRate(msg.value);

        // calculate token amount to be created
        uint256 tokens = bonusRate.mul(msg.value);

        bonusRate = 0;

        // update state
        weiRaised = weiRaised.add(msg.value);

        investorWei[msg.sender].amountOfWeiInvested = investorWei[msg.sender].amountOfWeiInvested.add(msg.value);

        investorWei[msg.sender].calculatedTokens = investorWei[msg.sender].calculatedTokens.add(tokens);

        TokenPurchase(msg.sender, beneficiary, msg.value, tokens);

        tokens = 0;
        
    }

    function getBonusRate(uint256 weiAmount) internal returns (uint256) {

        uint256 bonusRate = rate;

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

        return bonusRate;

    }

    function refundInvestment(uint256 weiAmount) public refundCondition {

        require(investorWei[msg.sender].amountOfWeiInvested >= weiAmount);

        investorWei[msg.sender].amountOfWeiInvested = investorWei[msg.sender].amountOfWeiInvested.sub(weiAmount);

        investorWei[msg.sender].calculatedTokens = 
            investorWei[msg.sender].calculatedTokens.sub(getBonusRate(weiAmount));

        weiRaised = weiRaised.sub(weiAmount);

        msg.sender.transfer(weiAmount);

    }

    // send ether to the fund collection wallet

    function safeWithdrawal() internal afterDeadline onlyOwner {
        
        uint256 funds = weiRaised;

        weiRaised = 0;

        if (funds > 0) {

            if (wallet.send(funds)) {

                Transferred(funds);

            } else {

                weiRaised = funds;

                revert();

            }

        }

    }

    function distributeTokens(address investor) internal onlyOwner afterDeadline {

        require(investorWei[msg.sender].amountOfWeiInvested > 0);

        investorWei[msg.sender].calculatedTokens = 0;

        token.mint(investor, investorWei[msg.sender].calculatedTokens);

    }

    // @return true if the transaction can buy tokens
    function validPurchase() internal constant returns (bool) {
        uint256 current = block.number;
        bool withinPeriod = current >= startBlock && current <= endBlock;
        bool nonZeroPurchase = msg.value != 0;
        bool withinCap = weiRaised.add(msg.value) <= weiCap;
        return withinCap && withinPeriod && nonZeroPurchase && !paused;
    }

    function terminateSale() onlyOwner {

        uint256 funds = weiRaised;

        weiRaised = 0;

        wallet.transfer(funds);

        suicide();

    }

}