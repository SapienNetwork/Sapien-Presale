pragma solidity ^0.4.18;

import "contracts/libraries/SafeMath.sol";
import "contracts/Owned.sol";
import "contracts/SapienStaking.sol";
import "contracts/libraries/ERC223.sol";

contract SapienToken is ERC223 {
  
    using SafeMath for uint256;

    Owned private owned;

    modifier onlyOwner() {
        require(msg.sender == owned.getOwner() || controller == msg.sender);
        _;
    }

    function tokenFallback(address _from, uint _value, bytes _data) public {
    
      require(msg.sender == stakeAddress);

      balances[_from] = balances[_from].add(_value);

      totalSupply = totalSupply.add(_value);
      
      FallbackData(_data);
    
    }

    function transfer(address _to, uint256 _value, bytes _data) public returns (bool) {
    
      require(_to != address(0));
      require(_value <= balances[msg.sender]);

      if(_to == stakeAddress && canStake == 1) {

          balances[msg.sender] = balances[msg.sender].sub(_value);

          SapienStaking receiver = SapienStaking(_to);
          receiver.tokenFallback(msg.sender, _value, _data);
        
          totalSupply = totalSupply.sub(_value);

          Transfer(msg.sender, _to, _value, _data);
          return true;

        } else if (!isContract(_to)) {

          return transferToAddress(_to, _value, _data);

        }

    }

    function SapienToken(address _owned, uint256 mintedTokens) {

        owned = Owned(_owned);
        totalSupply = mintedTokens;

    }

    function changeOwned(address _owned) {

        require(msg.sender == owned.getOwner());

        owned = Owned(_owned);

    }

    function changeController(address _controller) {

        require(msg.sender == owned.getOwner());

        controller = _controller;

    }

    function name() constant returns (string _name) {

        return name;

    }

    function symbol() constant returns (string _symbol) {

        return symbol;

    }

    function getDecimals() constant returns (uint256 _decimals) {

        return decimals;

    }

    function getTotalSupply() constant returns (uint256) {
        return totalSupply;
    }

    function isContract(address _addr) private returns (bool is_contract) {
      
        uint length;

        assembly {
                //retrieve the size of the code on target address, this needs assembly
                length := extcodesize(_addr)
        }

        return (length > 0);

    }

    function enableTransferToContract(address _stake) {

        require(msg.sender == owned.getOwner());

        canStake = 1;

        stakeAddress = _stake;

    }

    function disableTransferToContract() {

        require(msg.sender == owned.getOwner());

        canStake = 0;

        stakeAddress = 0x0000000000000000000000000000000000000000;
  
    }

    function balanceOf(address _owner) public constant returns (uint256 balance) {
        return balances[_owner];
    }

    function increaseCirculation(uint256 _amount) public onlyOwner {

        currentlyInCirculation = currentlyInCirculation.add(_amount);

    }

    function addToBalance(address _to, uint256 _amount) public onlyOwner {

        balances[_to] = balances[_to].add(_amount);

    }

    function transferToAddress(address _to, uint _value, bytes _data) internal returns (bool success) {
    
        if (balanceOf(msg.sender) < _value) 
            revert();
    
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        Transfer(msg.sender, _to, _value, _data);
        return true;

    }

}