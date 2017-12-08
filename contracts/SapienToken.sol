pragma solidity ^0.4.18;

import "contracts/libraries/SafeMath.sol";
import "contracts/Owned.sol";
import "contracts/SapienStaking.sol";
import "contracts/storage/SPNStorage.sol";
import "contracts/interfaces/ERC223.sol";

contract SapienToken is ERC223 {
  
    using SafeMath for uint256;

    Owned private owned;
    SPNStorage _storage;

    modifier onlyAllowedAddresses {
        require(msg.sender == owned.getOwner() || controller == msg.sender);
        _;
    }

    modifier onlyOwner {

        require(msg.sender == owned.getOwner());
        _;

    }

    function tokenFallback(address _from, uint _value, bytes _data) public {
    
      require(msg.sender == stakeAddress);
      require(_storage != SPNStorage(0));

      _storage.increaseUnstakedSPNBalance(_from, _value);

      currentlyInCirculation = currentlyInCirculation.add(_value);
      
      FallbackData(_data);
    
    }

    function transfer(address _to, uint256 _value, bytes _data) public returns (bool) {
    
      require(_to != address(0));
      require(_value <= balances[msg.sender]);
      require(_storage != SPNStorage(0));

      if(_to == stakeAddress && canStake == 1) {

          _storage.decreaseUnstakedSPNBalance(_from, _value);

          SapienStakingUInterface receiver = SapienStakingInterface(_to);
          receiver.tokenFallback(msg.sender, _value, _data);
        
          currentlyInCirculation = currentlyInCirculation.sub(_value);

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

    function changeSPNStorage(address _storageAddr) onlyOwner {

        _storage = SPNStorage(_storageAddr);

    }

    function changeOwned(address _owned) public onlyOwner {

        owned = Owned(_owned);

    }

    function changeController(address _controller) public onlyOwner {

        controller = _controller;

    }

    function name() public constant returns (string _name) {

        return name;

    }

    function symbol() public constant returns (string _symbol) {

        return symbol;

    }

    function getDecimals() public constant returns (uint256 _decimals) {

        return decimals;

    }

    function getTotalSupply() public constant returns (uint256) {
        return totalSupply;
    }

    function isContract(address _addr) private constant returns (bool is_contract) {
      
        uint length;

        assembly {
                //retrieve the size of the code on target address, this needs assembly
                length := extcodesize(_addr)
        }

        return (length > 0);

    }

    function enableStaking(address _stake) public onlyOwner {

        canStake = 1;

        stakeAddress = _stake;

    }

    function disableStaking() public onlyOwner {

        canStake = 0;

        stakeAddress = address(0);
  
    }

    function balanceOf(address _owner) public constant returns (uint256 balance) {
        
        require(_storage != SPNStorage(0));
        
        return _storage.getUnstakedBalance[_owner];
        
    }

    function addToBalance(address _to, uint256 _amount) public onlyAllowedAddresses {

        require(_storage != SPNStorage(0));

        _storage.increaseUnstakedSPNBalance(_to, _value);

    }

    function increaseCirculation(uint256 _amount) public onlyAllowedAddresses {

        require(currentlyInCirculation.add(_amount) <= totalSupply);

        currentlyInCirculation = currentlyInCirculation.add(_amount);

    }

    function transferToAddress(address _to, uint _value, bytes _data) internal returns (bool success) {
    
        if (balanceOf(msg.sender) < _value) 
            revert();

        require(_storage != SPNStorage(0));
    
         _storage.decreaseUnstakedSPNBalance(msg.sender, _value);
         _storage.increaseUnstakedSPNBalance(_to, _value);
        Transfer(msg.sender, _to, _value, _data);
        return true;

    }

}