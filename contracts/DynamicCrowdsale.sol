pragma solidity ^0.4.15;

import "contracts/Owned.sol";

contract DynamicCrowdsale {

    struct Stage {

        uint256 blockNumber;
        uint256 permittedInvestment;

    }

    /// @dev `owner` is the only address that can call a function with this
    /// modifier
    modifier onlyOwner() {
        require(msg.sender == owned.getOwner());
        _;
    }

    Owned private owned;
    Stage[] public stages;
    uint256 public position = 0;
    uint256 public maxPosition = 0;

    function DynamicCrowdsale(address _owned) {

        owned = Owned(_owned);

    }

    function addMilestone(uint256 block, uint256 investment) onlyOwner {

        require(stages[maxPosition].blockNumber < block);
        require(stages[maxPosition].permittedInvestment > investment);

        var stage = Stage(block, investment);

        stages.push(stage);

        maxPosition += 1;

    }

    function deleteMilestone(uint256 position) internal onlyOwner {

        delete stages[position];

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

    function setCurrentStage(uint256 stage) internal onlyOwner {

        position = stage;

    }

    function getCurrentMaxInvestment() public returns (uint256) {

        return stages[position].permittedInvestment;

    }

}