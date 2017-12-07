pragma solidity ^0.4.18;

contract ERC223 {

    mapping(address => uint256) balances;

    string public name = "SAPIEN COIN";
    string public symbol = "SPN";

    uint256 public decimals = 18;
    uint256 private canStake = 0;
    uint256 public totalSupply;
    uint256 public currentlyInCirculation = 0;

    address private controller;

    address private stakeAddress;
    
    event FallbackData(bytes _data);
    event Transfer(address indexed from, address indexed to, uint value, bytes indexed data);

    function tokenFallback(address _from, uint _value, bytes _data) public;

    /**
    * @dev transfer token for a specified address
    * @param _to The address to transfer to.
    * @param _value The amount to be transferred.
    */
    function transfer(address _to, uint256 _value, bytes _data) public returns (bool);

    function changeOwned(address _owned);

    function changeController(address _controller);

    // Function to access name of token .
    function name() constant returns (string _name);

    // Function to access symbol of token .
    function symbol() constant returns (string _symbol);

    // Function to access decimals of token .
    function getDecimals() constant returns (uint256 _decimals);

    // Function to access total supply of tokens .
    function getTotalSupply() constant returns (uint256);

    function isContract(address _addr) private returns (bool is_contract);

    function enableTransferToContract(address _stake);

    /**
    *@dev Disable staking in case of attack/vulnerability/etc
    */

    function disableTransferToContract();

    /**
    * @dev Gets the balance of the specified address.
    * @param _owner The address to query the the balance of.
    * @return An uint256 representing the amount owned by the passed address.
    */
    function balanceOf(address _owner) public constant returns (uint256 balance);

    function increaseCirculation(uint256 _amount) public;

    function addToBalance(address _to, uint256 _amount) public;

    //function that is called when transaction target is an address
    function transferToAddress(address _to, uint _value, bytes _data) internal returns (bool success);

}