pragma solidity ^0.4.18;

/// @author Stefan Ionescu - <codrinionescu@yahoo.com>

import "contracts/Owned.sol";
import "contracts/interfaces/TokenControllerInterface.sol";
import "contracts/interfaces/DynamicCrowdsaleInterface.sol";
import "contracts/interfaces/SapienCrowdsaleInterface.sol";
import "contracts/storage/CrowdsaleStorage.sol";
import "contracts/libraries/SafeMath.sol";

contract SapienCrowdsale is SapienCrowdsaleInterface {

    using SafeMath for uint256;

    //The storage for this crowdsale; we keep storage and logic separated in case we want to
    //upgrade this contract because of bugs, attacks etc
    CrowdsaleStorage internal _storage;

    //The contract interface which limits the amount of ether which can be sent at one time in the campaign
    DynamicCrowdsaleInterface internal dynamic;

    //SPN token Controller
    TokenControllerInterface internal token;

    //Contract which dictates who owns this campaign
    Owned private owned;

    //address where funds are collected
    address internal wallet;

    //for escape hatch; if 0, all functions can be used; if 1, only some functions can be used
    uint256 public blockAttack = 0;

     //maximum gas price for contribution transactions
    uint256 public MAX_GAS_PRICE = 2000000;

    //start and end times where investments are allowed (both inclusive)
    uint256 public startTime;
    uint256 public endTime;

    //how many token units a buyer gets per wei
    uint256 public rate;

    //amount of raised money in wei
    uint256 public weiRaised;

    //hard cap, campaign ends after reached
    uint256 public weiCap;

    //how much Ether an investor can actually invest in the crowdsale; if 0, any investor can send as much Ether as they want
    uint256 public investorLimit = 0;

    uint256 private oneEther = 10 ** 18;

    string public currentBadge;

    //allows for owner to pause the campaign if needed
    bool public paused;

    //investment milestones for participants in the crowdsale 
    //(ex: 33 eth, 100 eth, 500 eth, 1000 eth and 2000 eth)
    //used to determine bonuses

    mapping(uint256 => uint256) public bonusMilestones;
    mapping(uint256 => uint256) public bonusRates;

    modifier afterDeadline() {

        require(block.timestamp >= endTime);
         _;

    }

    //Used when we want to block the majority of functions from being called
    modifier hatch() {

        require(blockAttack == 0);
        _;

    }

    //Check if we paused campaign
    modifier notPaused() {
        require(!paused);
        _;
    }

    //Check that campaign didn't end in order to allow refunds
    modifier refundCondition() {

        require(block.timestamp < endTime);
        _;

    }

    //verifies that gas price is below max gas price (prevents "cutting in line")
    modifier validGasPrice() {
        require(tx.gasprice <= MAX_GAS_PRICE);
        _;
    }

    ///@dev `owner` is the only address that can call a function with this
    ///modifier
    modifier onlyOwner() {
        require(msg.sender == owned.getOwner());
        _;
    }

    function SapienCrowdsale(address _owned) {
        paused = false;
        owned = Owned(_owned);
    }

     function changeOwned(address _owned) public onlyOwner {

        owned = Owned(_owned);

    }

    function initialize(uint256 hoursUntilStart, uint256 hoursUntilEnd, uint256 _rate, address _wallet, uint256 _cap, address _token, address _storageAddress, string badge) public onlyOwner hatch {

        require(hoursUntilStart >= 0);
        require(hoursUntilEnd >= 0);
        require(_rate > 0);
        require(_wallet != 0x0);
        require(_cap > 0);
        require(_token != 0x0);

        startTime = block.timestamp + hoursUntilStart * 1 hours;
        endTime = startTime + hoursUntilEnd * 1 hours;
        rate = _rate;
        wallet = _wallet;
        weiCap = _cap;
        token = TokenControllerInterface(_token);
        _storage = CrowdsaleStorage(_storageAddress);

        currentBadge = badge;

    }

    function changeBonusMilestone(uint256 position, uint256 newValue) public onlyOwner hatch {

        bonusMilestones[position] = newValue;

    }

    function changeBonusRate(uint256 position, uint256 newValue) public onlyOwner hatch {

        bonusRates[position] = newValue;

    }

    function changeDynamic(address _dynamic) public onlyOwner hatch {

        dynamic = DynamicCrowdsaleInterface(_dynamic);

    }

    function changeCrowdsaleStorage(address _storageAddress) public onlyOwner hatch {

        _storage = CrowdsaleStorage(_storageAddress);

    }

    // Pauses the contribution if there is any issue
    function pauseContribution() public onlyOwner {
        paused = true;
    }

    // Resumes the contribution
    function resumeContribution() public onlyOwner hatch {
        paused = false;
    }

    function switchTokenController(address _token) public onlyOwner hatch {

        token = TokenControllerInterface(_token);

    }

    function switchWallet(address _wallet) public onlyOwner hatch {

        wallet = _wallet;

    }

    // use only official function to buy tokens
    function () payable {
        buyTokens();
    }

    function limitPerInvestor(uint256 limit) public onlyOwner hatch {

        investorLimit = limit;

    }

    function changeBaseRate(uint256 baseRate) public onlyOwner hatch {

        rate = baseRate;

    }

    function changeMaximumGasLimit(uint256 gasLimit) public onlyOwner {

        MAX_GAS_PRICE = gasLimit;

    }

    function computeAllowedInvestment(uint256 investment) public constant returns (uint256) {

        uint256 allowed = 0;
        
        /**
        * Check if we set a dynamic ceiling for the crowdsale
        * If yes, see how much an investor can invest at this stage
        * If no, just get the invested amount and continue 
        */
        if (dynamic != address(0)) {

            allowed = dynamic.allowedInvestment(msg.value);

        } else {

            allowed = msg.value;
                
        }

        /**
        * Check if we have an overall limit per investor
        * If yes, see if the investor's sum gets past the limit, and if so,
        * set the investor's total investment to max
        */

        if (investorLimit != 0) {

            uint256 storageWei = _storage.getInvestorWei(msg.sender);

            require(storageWei < investorLimit);

            if (allowed.add(storageWei) > investorLimit) {

                allowed = investorLimit.sub(storageWei);

            }

        }

        return allowed;

    }

    function buyTokens() public payable validGasPrice hatch {
        
        require(msg.value > 0);
        require(_storage != CrowdsaleStorage(0));

        uint256 allowed = computeAllowedInvestment(msg.value);

        //Make necessary checks: the campaign didn't end, the investor is not a contract etc
     
        require(allowed > 0);

        require(validPurchase(msg.sender, allowed));

        //Compute the bonus for each investment
        uint256 bonusRate = getBonusRate(allowed);

        uint256 getEtherAmount;
      
        getEtherAmount = uint(allowed) / uint(10**18);

        //Calculate token amount to be created
        uint256 tokens = bonusRate.mul(getEtherAmount);

        //Add the investment to wei raised
        weiRaised = weiRaised.add(allowed);

        //Update investor's info
        _storage.addInvestment(msg.sender, allowed, tokens);

        //Set investor's badge
        _storage.setBadge(msg.sender, currentBadge);

        //Broadcast event
        TokenPurchase(msg.sender, allowed, tokens);

        tokens = 0;

        //Send back ether if the investor sent above the limit
        if (msg.value != allowed) {

            msg.sender.transfer(msg.value.sub(allowed));

        }
        
    }

    function getBonusRate(uint256 weiAmount) public constant returns (uint256) {

        uint256 bonus = rate;

        if (weiAmount >= bonusMilestones[0] * oneEther && weiAmount < bonusMilestones[1] * oneEther) {

            bonus = bonusRates[0];

        } else if (weiAmount >= bonusMilestones[1] * oneEther && weiAmount < bonusMilestones[2] * oneEther) {

            bonus = bonusRates[1];

        } else if (weiAmount >= bonusMilestones[2] * oneEther && weiAmount < bonusMilestones[3] * oneEther) {

            bonus = bonusRates[2];

        } else if (weiAmount >= bonusMilestones[3] * oneEther && weiAmount < bonusMilestones[4] * oneEther) {

            bonus = bonusRates[3];

        } else if (weiAmount >= bonusMilestones[4] * oneEther) {

            bonus = bonusRates[4];

        }

        return bonus;

    }

    function refundInvestment(uint256 weiAmount) public refundCondition {

        require(_storage != CrowdsaleStorage(0));
        require(_storage.getInvestorWei(msg.sender) >= weiAmount);
        require(weiAmount > 0);

        _storage.withdrawInvestment(msg.sender, weiAmount, getBonusRate(weiAmount));

        weiRaised = weiRaised.sub(weiAmount);

        if (_storage.getInvestorWei(msg.sender).sub(weiAmount) == 0) {

            _storage.setBadge(msg.sender, "NONE");

        }

        msg.sender.transfer(weiAmount);

    }

    function safeWithdrawal() public //afterDeadline 
    onlyOwner hatch {
        
        require(wallet != address(0));

        uint256 funds = weiRaised;

        weiRaised = 0;

        if (funds > 0) {

            wallet.transfer(funds);

            TransferredToWallet(funds);

        } else {

            weiRaised = funds;

            revert();

        }

    }

    function distributeTokens(address investor) public onlyOwner afterDeadline {

        require(_storage != CrowdsaleStorage(0));

        uint256 investorWei = _storage.getInvestorWei(investor);

        require(investor != address(0));
        require(investorWei > 0);

        uint256 tokensToSend = _storage.getInvestorTokens(investor);

        _storage.withdrawInvestment(investor, investorWei, tokensToSend);

        token.allocateTokens(investor, tokensToSend);

        AllocateTokens(msg.sender, investor, tokensToSend);

    }

    function claimTokens() public afterDeadline {

        require(_storage != CrowdsaleStorage(0));

        uint256 investorWei = _storage.getInvestorWei(msg.sender);

        require(investorWei > 0);

        uint256 tokensToSend = _storage.getInvestorTokens(msg.sender);

        _storage.withdrawInvestment(msg.sender, investorWei, tokensToSend);

        token.allocateTokens(msg.sender, tokensToSend);

        AllocateTokens(msg.sender, msg.sender, tokensToSend);

    }

    function validPurchase(address investor, uint256 allowed) internal returns (bool) {
        uint256 current = block.timestamp;
        bool withinPeriod = current >= startTime && current <= endTime;
        bool withinCap = weiRaised.add(allowed) <= weiCap;
        bool investorIsContract = isContract(investor);
        return withinCap && withinPeriod && !paused && !investorIsContract;
    }

    function isContract(address _addr) internal constant returns (bool is_contract) {
      
      uint length;

      assembly {
            //retrieve the size of the code on target address, this needs assembly
            length := extcodesize(_addr)
      }

      return (length > 0);

    }

    function escapeHatch() public onlyOwner {

        if (blockAttack == 0) {

            blockAttack = 1;

        } else {

            blockAttack = 0;

        }
            
    }

}