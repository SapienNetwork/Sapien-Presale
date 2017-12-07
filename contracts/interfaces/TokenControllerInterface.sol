pragma solidity ^0.4.18;

contract TokenControllerInterface {

    address private crowdsale;

    event Allocate(address indexed to, uint256 amount);

    function changeBasicToken(address _sapien) public;

    function changeOwned(address _owned) public;

    function changeCrowdsale(address _crowdsale) public;

    function allocateTokens(address _to, uint256 _amount) returns (bool);

    function upgrade();

}