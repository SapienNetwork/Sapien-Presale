pragma solidity ^0.4.15;

import './Ownable.sol';
import 'node_modules/zeppelin-solidity/contracts/math/SafeMath.sol';

contract SapienStaking is Ownable {

    using SafeMath for uint256;

    struct SPNUser {

        uint256 stakedAmount;
        bytes32 id;

    }

    mapping (address => SPNUser) stakingBalances;

    event StakedFunds(address _from, uint256 amountSPN);
    event NotEnoughFunds(bytes32 message);


    function SapienStaking() {}

    function addStakeFunds(uint256 spnAmount) {

        stakingBalances[msg.sender].stakedAmount.add(spnAmount);

        StakedFunds(msg.sender, spnAmount);

    }

    function consumeSPN(uint256 amount) {

       // TODO: HAVE TO CHECK IF USER EVER STAKED ANY AMOUNT OF SPN; POSSIBLY USE THE ID FROM THE SAPIEN PLATFORM

        if (stakingBalances[msg.sender].stakedAmount.sub(amount) < 0) {

            NotEnoughFunds("You don't have enough SPN to do this! Stake more SPN in order to continue");

            revert();

        }

        stakingBalances[msg.sender].stakedAmount.sub(amount);

    }

    function urgentWithdrawFromUser(address _from) onlyOwner {

        uint256 amount = stakingBalances[_from].stakedAmount;

        stakingBalances[_from].stakedAmount.sub(amount);

    }

}