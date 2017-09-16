pragma solidity ^0.4.13;

import "zeppelin/contracts/crowdsale/Crowdsale.sol";
import "./SapienCoin.sol";

contract SapienCrowdSale is Crowdsale {

    function SapienCrowdSale(uint256 _startBlock, uint256 _endBlock, uint256 _rate, address _wallet) Crowdsale(_startBlock, _endBlock, _rate, _wallet) {
    }

    // creates the token to be sold.
    function createTokenContract() internal returns (MintableToken) {
        return new SapienCoin();
    }
}