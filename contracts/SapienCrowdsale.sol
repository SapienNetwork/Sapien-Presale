pragma solidity ^0.4.13;

import "./SapienCoin.sol";
import "node_modules/zeppelin-solidity/contracts/math/SafeMath.sol";
import "./Owned.sol";

contract SapienCrowdSale is Owned {

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
    SapienCoin public token;

    //allows for owner to pause the campaign if needed
    bool public paused;



    modifier notPaused() {
        require(!paused);
        _;
    }

    // verifies that gas price is below max gas price (prevents "cutting in line")
    modifier validGasPrice() {
        require(tx.gasprice <= MAX_GAS_PRICE);
        _;
    }

    function SapienCrowdSale() {
        paused = false;
    }

    function initalize(uint256 _startBlock, uint256 _endBlock, uint256 _rate, address _wallet, uint256 _cap, address _token) onlyOwner {

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
        token = SapienCoin(_token);

    }

    // Pauses the contribution if there is any issue
    function pauseContribution() onlyOwner {
        paused = true;
    }

    // Resumes the contribution
    function resumeContribution() onlyOwner {
        paused = false;
    }

    /**
     * event for token purchase logging
     * @param purchaser who paid for the tokens
     * @param beneficiary who got the tokens
     * @param value weis paid for purchase
     * @param amount amount of tokens purchased
     */
    event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);

    // fallback function can be used to buy tokens
    function () payable {
        buyTokens(msg.sender);
    }

    // low level token purchase function
    function buyTokens(address beneficiary) payable validGasPrice {
        require(beneficiary != 0x0);
        require(validPurchase());

        uint256 weiAmount = msg.value;

        uint256 bonusRate = rate;

        if (weiAmount > 33 * 10**18 && weiAmount < 166 * 10**18) {

            bonusRate = 2575;

        } else if (weiAmount > 166 * 10**18 && weiAmount < 333 * 10**18) {

            bonusRate = 2675;

        } else if (weiAmount > 333 * 10**18 && weiAmount < 833 * 10**18) {

            bonusRate = 2875;

        } else if (weiAmount > 833 * 10**18 && weiAmount < 1666 * 10**18) {

            bonusRate = 3000;

        } else if (weiAmount > 1666 * 10**18) {

            bonusRate = 3750;

        }

        // calculate token amount to be created
        uint256 tokens = weiAmount.mul(bonusRate);

        // update state
        weiRaised = weiRaised.add(weiAmount);

        token.mint(beneficiary, tokens);
        TokenPurchase(msg.sender, beneficiary, weiAmount, tokens);

        forwardFunds();
        
    }

    // send ether to the fund collection wallet
    function forwardFunds() internal {
        wallet.transfer(msg.value);
    }

    // @return true if the transaction can buy tokens
    function validPurchase() internal constant returns (bool) {
        uint256 current = block.number;
        bool withinPeriod = current >= startBlock && current <= endBlock;
        bool nonZeroPurchase = msg.value != 0;
        bool withinCap = weiRaised.add(msg.value) <= weiCap;
        return withinCap && withinPeriod && nonZeroPurchase && !paused;
    }

    // @return true if crowdsale event has ended
    function hasEnded() public constant returns (bool) {
        bool capReached = weiRaised >= weiCap;
        return capReached || block.number > endBlock;
    }

}
