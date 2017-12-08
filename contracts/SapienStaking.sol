pragma solidity ^0.4.18;

import "contracts/Owned.sol";
import "contracts/libraries/StringUtils.sol";
import "contracts/SapienToken.sol";
import "contracts/storage/SPNStorage.sol";
import "contracts/libraries/SafeMath.sol";
import "contracts/interfaces/SapienStakingInterface.sol";

contract SapienStaking is SapienStakingInterface {

    using SafeMath for uint256;

    Owned private owned;

    SPNStorage _storage;

    modifier onlyOwner() {
        require(msg.sender == owned.getOwner());
        _;
    }

    modifier hatch() {

        require(blockAttack == 0);
        _;

    }

    function tokenFallback(address _from, uint _value, bytes _data) public {
        
        require(msg.sender != address(0));    
    
        require(msg.sender == sapienToken);

        require(_storage != SPNStorage(0));

        _storage.increaseStakedSPNBalance(_from, _value);
      
        FallbackData(_data);
    
    }

  /**
  * @dev transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value, bytes _data) public returns (bool) {
    
        require(_to == sapienToken);
        require(_value <= stakedAmounts[msg.sender]);
        require(_storage != SPNStorage(0));

        if (_to == sapienToken) {

          _storage.decreaseStakedSPNBalance(msg.sender, _value);

          ERC223 receiver = ERC223(_to);
          receiver.tokenFallback(msg.sender, _value, _data);

          Transfer(msg.sender, _to, _value, _data);
        
          return true;

        }

    }

    function SapienStaking(address _token, address _owned) {
        
        sapienToken = _token;
        owned = Owned(_owned);
        
    }

    function() payable {

        revert();

    }

    function changeActionCost(string _action, uint256 tokenAmount) public onlyOwner {

        actions[_action] = tokenAmount;

    }

    function changeSPNStorage(address _storageAddr) onlyOwner {

        _storage = SPNStorage(_storageAddr);

    }

    function deleteAction(string _action) public onlyOwner {

        actions[_action] = 0;

    }

    function addAction(string actionName, uint256 cost) public onlyOwner {

        actions[actionName] = cost;

    }

    function changeTokenAddress(address _token) public onlyOwner {

        sapienToken = _token;

    }
    
    function balanceOf(address _owner) public constant returns (uint256 balance) {
      return _storage.getStakedBalance(_owner);
    }

    function tipUser(address _to, uint256 _amount) public hatch {

        require(balances[msg.sender] >= _amount);
        require(_amount > 0);
        require(_storage != SPNStorage(0));

        _storage.decreaseStakedSPNBalance(msg.sender, _value);

        _storage.decreaseStakedSPNBalance(_to, _value);

        Tipped(msg.sender, _to, _amount);

    }

    function interactWithSapien(string _action, address _user) public hatch {

        require(msg.sender == _user);
        require(actions[_action] > 0);
        require(_storage != SPNStorage(0));
        require(stakedAmounts[_user] > actions[_action]);

        _storage.decreaseStakedSPNBalance(_user, actions[_action]);

        MadeAnAction(_action, actions[_action]);

    }

    function escapeHatch() public onlyOwner {

        if (blockAttack == 0) {

            blockAttack = 1;

        } else {

            blockAttack = 0;

        }
            
    }

    function upgrade() public onlyOwner {

        

    }

}