pragma solidity ^0.4.18;

contract DynamicCrowdsaleInterface {

    function changeOwned(address _owned) public;
    function addMilestone(uint256 block, uint256 investment) public;
    function deleteMilestone(uint256 position) public;
    function allowedInvestment(uint256 totalWei) public returns (uint256);
    function getCurrentStage() public returns (uint256);
    function setCurrentStage(uint256 stage) public;
    function getCurrentMaxInvestment() public returns (uint256);

}