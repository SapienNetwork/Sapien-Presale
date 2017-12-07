pragma solidity ^0.4.18;

import "contracts/Owned.sol";
import "contracts/TokenController.sol";
import "contracts/DynamicCrowdsale.sol";
import "contracts/interfaces/SapienCrowdsaleInterface.sol";
import "contracts/libraries/SafeMath.sol";

contract SapienCrowdsale is SapienCrowdsaleInterface {

    using SafeMath for uint256;

    DynamicCrowdsale dynamic;

    //SPN token Controller
    TokenController public token;

    Owned private owned;

    modifier afterDeadline() {

        require(block.number >= endBlock);
         _;

    }

    modifier hatch() {

        require(blockAttack == 0);
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

    function SapienCrowdsale(address _owned, address utilsAddress, address dynamicAddress) {
        paused = false;
        owned = Owned(_owned);
        dynamic = DynamicCrowdsale(dynamicAddress);
    }

     function changeOwned(address _owned) public onlyOwner {

        owned = Owned(_owned);

    }

    function initialize(uint256 _startBlock, uint256 _endBlock, uint256 _rate, address _wallet, uint256 _cap, address _token) onlyOwner hatch {

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

    function changeBonusMilestone(uint256 position, uint256 newValue) public onlyOwner hatch {

        bonusMilestones[position] = newValue;

    }

    function changeBonusRate(uint256 position, uint256 newValue) public onlyOwner hatch {

        bonusRates[position] = newValue;

    }

    // Pauses the contribution if there is any issue
    function pauseContribution() public onlyOwner {
        paused = true;
    }

    // Resumes the contribution
    function resumeContribution() onlyOwner {
        paused = false;
    }

    function switchSapienToken(address _token) onlyOwner {

        token = TokenController(_token);

    }

    function switchWallet(address _wallet) onlyOwner {

        wallet = _wallet;

    }

    // fallback function can be used to buy tokens
    function () payable {
        buyTokens(msg.sender);
    }

    function limitPerInvestor(uint256 limit) public onlyOwner hatch {

        investorLimit = limit;

    }

    function changeBaseRate(uint256 baseRate) onlyOwner hatch {

        rate = baseRate;

    }

    function buyTokens(address beneficiary) payable validGasPrice hatch {
        
        require(beneficiary != 0x0);
        require(msg.value > 0);

        uint256 allowed = 0;
        
        if (dynamic != address(0)) {

            allowed = dynamic.allowedInvestment(msg.value);

        } else {

            allowed = msg.value;
                
        }

        if (limitPerInvestor != 0) {

            require(investorInfo[msg.sender].amountOfWeiInvested < limitPerInvestor);

            if (allowed.add(investorInfo[msg.sender].amountOfWeiInvested) > limitPerInvestor) {

                allowed = limitPerInvestor.sub(investorInfo[msg.sender].amountOfWeiInvested);

            }

        }

        require(validPurchase(msg.sender, allowed));

        uint256 bonusRate = getBonusRate(allowed);

        // calculate token amount to be created
        uint256 tokens = bonusRate.mul(allowed);

        bonusRate = 0;

        // update state
        weiRaised = weiRaised.add(allowed);

        investorInfo[msg.sender].amountOfWeiInvested = investorInfo[msg.sender].amountOfWeiInvested.add(allowed);

        investorInfo[msg.sender].calculatedTokens = investorInfo[msg.sender].calculatedTokens.add(tokens);

        TokenPurchase(msg.sender, beneficiary, allowed, tokens);

        tokens = 0;

        if (msg.value != allowed) {

            msg.sender.transfer(msg.value.sub(allowed));

        }
        
    }

    function getBonusRate(uint256 weiAmount) internal returns (uint256) {

        uint256 bonus = rate;

        if (weiAmount >= bonusMilestones[0] * 10**18 && weiAmount < bonusMilestones[1] * 10**18) {

            bonus = bonusRates[0];

        } else if (weiAmount >= bonusMilestones[1] * 10**18 && weiAmount < bonusMilestones[2] * 10**18) {

            bonus = bonusRates[1];

        } else if (weiAmount >= bonusMilestones[2] * 10**18 && weiAmount < bonusMilestones[3] * 10**18) {

            bonus = bonusRates[2];

        } else if (weiAmount >= bonusMilestones[3] * 10**18 && weiAmount < bonusMilestones[4] * 10**18) {

            bonus = bonusRates[3];

        } else if (weiAmount >= bonusMilestones[4] * 10**18) {

            bonus = bonusRates[4];

        }

        return bonus;

    }


    function refundInvestment(uint256 weiAmount) public refundCondition {

        require(investorInfo[msg.sender].amountOfWeiInvested >= weiAmount);

        investorInfo[msg.sender].amountOfWeiInvested = investorInfo[msg.sender].amountOfWeiInvested.sub(weiAmount);

        investorInfo[msg.sender].calculatedTokens = 
            investorInfo[msg.sender].calculatedTokens.sub(getBonusRate(weiAmount));

        weiRaised = weiRaised.sub(weiAmount);

        msg.sender.transfer(weiAmount);

    }

    // send ether to the fund collection wallet

    function safeWithdrawal() public afterDeadline onlyOwner hatch {
        
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

    function distributeTokens(address investor) public onlyOwner afterDeadline {

        require(investorInfo[investor].amountOfWeiInvested > 0);

        uint256 tokensToSend = investorInfo[investor].calculatedTokens;

        investorInfo[investor].calculatedTokens = 0;

        token.allocateTokens(investor, tokensToSend);

    }

    function claimTokens() public afterDeadline {

        require(investorInfo[msg.sender].amountOfWeiInvested > 0);

        uint256 tokensToSend = investorInfo[msg.sender].calculatedTokens;

        investorInfo[msg.sender].calculatedTokens = 0;

        token.allocateTokens(msg.sender, tokensToSend);

    }

    // @return true if the transaction can buy tokens
    function validPurchase(address investor, uint256 allowed) internal constant returns (bool) {
        uint256 current = block.number;
        bool withinPeriod = current >= startBlock && current <= endBlock;
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