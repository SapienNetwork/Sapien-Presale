pragma solidity ^0.4.18;

contract ERC223 {

    event FallbackData(bytes _data);
    event Transfer(address indexed from, address indexed to, uint value, bytes indexed data);

    //Called when contract receives tokens
    function tokenFallback(address _from, uint _value, bytes _data) public;

    /**
    * @dev transfer token for a specified address
    * @param _to The address to transfer to.
    * @param _value The amount to be transferred.
    */
    function transfer(address _to, uint256 _value, bytes _data) public returns (bool);

    //Change the owner of the contract
    function changeOwned(address _owned) public;

    // Function to access name of token .
    function name() public constant returns (string _name);

    // Function to access symbol of token .
    function symbol() public constant returns (string _symbol);

    // Function to access decimals of token .
    function getDecimals() public constant returns (uint256 _decimals);

    // Function to access total supply of tokens .
    function getTotalSupply() public constant returns (uint256);

    //Check if an address is from a contract
    function isContract(address _addr) private constant returns (bool is_contract);

    //Change the storage where we manage unstaked SPN
    function changeSPNStorage(address _storageAddr);

    /**
    * @dev Gets the balance of the specified address.
    * @param _owner The address to query the the balance of.
    * @return An uint256 representing the amount owned by the passed address.
    */
    function balanceOf(address _owner) public constant returns (uint256 balance);

    function escapeHatch() public;

}