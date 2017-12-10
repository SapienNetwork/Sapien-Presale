pragma solidity ^0.4.18;

/// @author Stefan Ionescu - <codrinionescu@yahoo.com>

import "contracts/interfaces/ERC223.sol";

contract SapienStakingInterface is ERC223 {

    event Transfer(address indexed from, address indexed to, uint value, bytes indexed data);
    event Tipped(address _from, address _to, uint256 _amount);
    event FallbackData(bytes _data);
    event MadeAnAction(address who, string action, uint256 amount);

    /**
    * Sapien has different actions which can be pero=formed by users
    * here the contract owner sets the SPN cost for each action
    */
    function changeActionCost(string _action, uint256 tokenAmount) public;

    //Change the storage where we manage staked tokens
    function changeSPNStorage(address _storageAddr);

    //Eliminate action from Sapien
    function deleteAction(string _action) public;

    //Add an action to Sapien
    function addAction(string actionName, uint256 cost) public;

    //Change the address of the contract where we manage unstaked tokens
    function changeTokenAddress(address _token) public;

    //Tip a user on the platform with staked SPN
    function tipUser(address _to, uint256 _amount) public;

    //Called when user does something on the platform (comment, post, vote etc)
    function interactWithSapien(string _action) public;

}