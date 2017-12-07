pragma solidity ^0.4.18;

import "contracts/Owned.sol";
import "contracts/libraries/StringUtils.sol";
import "contracts/SapienToken.sol";
import "contracts/libraries/SafeMath.sol";

contract SapienStaking {

    using SafeMath for uint256;

    Owned private owned;

    address private sapienToken;

    uint256 blockAttack = 0;
    uint256 public timeUntilNoWithdrawalFees = 365 days;

    mapping(address => uint256) balances;
    mapping(string => uint256) public actions;

    mapping(uint256 => uint256) public fees;
    
    event Transfer(address indexed from, address indexed to, uint value, bytes indexed data);
    event Tipped(address _from, address _to, uint256 _amount);
    event FallbackData(bytes _data);
    event MadeAnAction(string action, uint256 amount);

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

        balances[_from] = balances[_from].add(_value);
      
        FallbackData(_data);
    
    }

  /**
  * @dev transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value, bytes _data) public returns (bool) {
    
        require(_to == sapienToken);
        require(_value <= balances[msg.sender]);

        if (_to == sapienToken) {

          balances[msg.sender] = balances[msg.sender].sub(_value);

          SapienToken receiver = SapienToken(_to);
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

    function deleteAction(string _action) public onlyOwner {

        actions[_action] = 0;

    }

    function addAction(string actionName, uint256 cost) public onlyOwner {

        actions[actionName] = cost;

    }

    function changeTokenAddress(address _token) public onlyOwner {

        sapienToken = _token;

    }

    function changeFee(uint256 month, uint256 feeAmount) public onlyOwner {

        fees[month] = feeAmount;

    }
    
    function balanceOf(address _owner) public constant returns (uint256 balance) {
      return balances[_owner].add(currentlyUsed[_owner]);
    }

    function tipUser(address _to, uint256 _amount) public hatch {

        require(balances[msg.sender] >= _amount);

        balances[msg.sender] = balances[msg.sender].sub(_amount);

        balances[_to] = balances[_to].add(_amount);

        Tipped(msg.sender, _to, _amount);

    }

    function interactWithSapien(string _action, address _user) public hatch {

        require(msg.sender == _user);
        require(actions[_action] > 0);
        require(balances[_user] > actions[_action]);

        balances[_user] = balances[_user].sub(actions[_action]);

    }

    function escapeHatch() public onlyOwner {

        if (blockAttack == 0) {

            blockAttack = 1;

        } else {

            blockAttack = 0;

        }
            
    }

}