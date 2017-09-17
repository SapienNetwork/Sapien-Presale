pragma solidity ^0.4.13;

import "zeppelin/contracts/crowdsale/CappedCrowdsale.sol";
import "./SapienCoin.sol";
import "zeppelin/contracts/math/SafeMath.sol";


contract SapienCrowdSale is CappedCrowdsale {
    using SafeMath for uint256;

    function SapienCrowdSale(uint256 _startBlock, uint256 _endBlock, uint256 _rate, address _wallet, uint256 _cap)
        CappedCrowdsale (_cap) Crowdsale(_startBlock, _endBlock, _rate, _wallet) {


    }

    function createTokenContract() internal returns (MintableToken) {
        return new SapienCoin();
    }

}