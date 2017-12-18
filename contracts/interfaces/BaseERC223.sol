pragma solidity ^0.4.18;

contract BaseERC223 {

    event FallbackData(bytes _data);
    event Transfer(address from, address to, uint value, bytes data);

    //Called when contract receives tokens
    function tokenFallback(address _from, uint _value, bytes _data) public;

    /**
    * @dev transfer token for a specified address
    * @param _to The address to transfer to.
    * @param _value The amount to be transferred.
    */
    function transfer(address _to, uint256 _value, bytes _data) public returns (bool);

}