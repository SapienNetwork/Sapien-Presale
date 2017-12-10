pragma solidity ^0.4.18;

/// @author Stefan Ionescu - <codrinionescu@yahoo.com>

import "contracts/Owned.sol";
import "contracts/libraries/SafeMath.sol";

contract CrowdsaleStorage {

    using SafeMath for uint256;

    Owned owned;

    modifier onlyOwner {

        require(msg.sender == owned.getOwner());
        _;

    }

    modifier onlyAllowedContracts {

        require(allowedContracts[msg.sender] == 1);
        _;

    }

    struct Investor {

        uint256 amountOfWeiInvested;
        uint256 calculatedTokens;

    }

    mapping(address => uint256) allowedContracts;

    //Here we store the information about an investor (wei and amount of tokens for them) until
    //the campaign finishes 
    mapping(address => Investor) public investorInfo;

    function CrowdsaleStorage(address _owned) {

        owned = Owned(_owned);

    }

     function changeOwner(address _owned) public onlyOwner {

        owned = Owned(_owned);

    }

    function addContract(address _contract) public onlyOwner {

        allowedContracts[_contract] = 1;

    }

    function deleteContract(address _contract) public onlyOwner {

        require(allowedContracts[_contract] == 1);

        allowedContracts[_contract] = 0;

    }

    //Get total amount of wei an investor sent to the campaign
    function getInvestorWei(address investor) public constant returns (uint256) {

        return investorInfo[investor].amountOfWeiInvested;

    }

    //Get how much tokens will be allocated to investor
    function getInvestorTokens(address investor) public constant returns (uint256) {

        return investorInfo[investor].calculatedTokens;

    }

    function addInvestment(address investor, uint256 weiAmount, uint256 tokenAmount) public onlyAllowedContracts returns (bool) {

        //Set for each investor the wei and tokens amounts
        investorInfo[investor].amountOfWeiInvested = investorInfo[investor].amountOfWeiInvested.add(weiAmount);

        investorInfo[investor].calculatedTokens = investorInfo[investor].calculatedTokens.add(tokenAmount);

        return true;

    }

    function withdrawInvestment(address investor, uint256 weiAmount, uint256 tokenAmount) public onlyAllowedContracts returns (bool) {

        investorInfo[investor].amountOfWeiInvested = investorInfo[investor].amountOfWeiInvested.sub(weiAmount);

        investorInfo[investor].calculatedTokens = 
            investorInfo[investor].calculatedTokens.sub(tokenAmount);

        return true;

    }

}