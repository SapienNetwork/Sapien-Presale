pragma solidity ^0.4.18;

/// @author Stefan Ionescu - <codrinionescu@yahoo.com>

import "contracts/Owned.sol";
import "contracts/interfaces/DynamicCrowdsaleInterface.sol";

contract DynamicCrowdsale is DynamicCrowdsaleInterface {

    Stage[] public stages;
    uint256 public position = 0;
    uint256 public maxPosition = 0;

    Owned private owned;

    struct Stage {

        uint256 blockNumber;
        uint256 permittedInvestment;

    }

    modifier onlyOwner() {
        require(msg.sender == owned.getOwner());
        _;
    }

    function DynamicCrowdsale(address _owned) {

        owned = Owned(_owned);

    }

    function() payable {

        revert();

    }

     function changeOwned(address _owned) public onlyOwner {

        owned = Owned(_owned);

    }

    function addMilestone(uint256 blockNR, uint256 investment) public onlyOwner {

        require(stages[maxPosition].blockNumber < blockNR);
        require(stages[maxPosition].permittedInvestment > investment);

        var stage = Stage(blockNR, investment);

        stages.push(stage);

        maxPosition += 1;

    }

    function deleteMilestone(uint256 _position) public onlyOwner {

        delete stages[_position];

        for (uint i = _position; i < maxPosition - 1; i++) {

            stages[i] = stages[i + 1];

        }

        maxPosition -= 1;

    }

    function allowedInvestment(uint256 totalWei) public returns (uint256) {

        if (totalWei > stages[position].permittedInvestment) {

            return stages[position].permittedInvestment;

        } else {

            return totalWei;

        }
            
    }

    function getCurrentStage() public returns (uint256) {

        return position;

    }

    function setCurrentStage(uint256 stage) public onlyOwner {

        position = stage;

    }

    function getCurrentMaxInvestment() public returns (uint256) {

        return stages[position].permittedInvestment;

    }

}