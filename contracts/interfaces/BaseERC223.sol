pragma solidity ^0.4.15;

contract BaseERC223 {

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

}