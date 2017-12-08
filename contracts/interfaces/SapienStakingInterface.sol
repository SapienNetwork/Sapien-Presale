pragma solidity ^0.4.18;

contract SapienStakingInterface {

    address private sapienToken;

    uint256 blockAttack = 0;

    mapping(string => uint256) private actions;

    event Transfer(address indexed from, address indexed to, uint value, bytes indexed data);
    event Tipped(address _from, address _to, uint256 _amount);
    event FallbackData(bytes _data);
    event MadeAnAction(string action, uint256 amount);

    function tokenFallback(address _from, uint _value, bytes _data) public;

    function transfer(address _to, uint256 _value, bytes _data) public returns (bool);

    function changeActionCost(string _action, uint256 tokenAmount) public;

    function changeSPNStorage(address _storageAddr);

    function deleteAction(string _action) public;

    function addAction(string actionName, uint256 cost) public;

    function changeTokenAddress(address _token) public;

    function changeActions();

    function balanceOf(address _owner) public constant returns (uint256 balance);

    function tipUser(address _to, uint256 _amount) public;

    function interactWithSapien(string _action, address _user) public;

    function escapeHatch() public;

    function upgrade() public;

}