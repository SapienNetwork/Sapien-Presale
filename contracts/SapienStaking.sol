pragma solidity ^0.4.15;

import "contracts/Owned.sol";
import "contracts/StringUtils.sol";
import "node_modules/zeppelin-solidity/contracts/token/SapienToken.sol";
import "node_modules/zeppelin-solidity/contracts/math/SafeMath.sol";

contract SapienStaking {

    using SafeMath for uint256;

    Owned private owned;

    address private sapienToken;

    uint256 public forVote = 1;
    uint256 public forComment = 5;
    uint256 public forPosting = 10;

    mapping (address => uint256) balances;
    
    event Transfer(address indexed from, address indexed to, uint value, bytes indexed data);

     modifier onlyOwner() {
        require(msg.sender == owned.getOwner());
        _;
    }
    
    event StakedForAction(uint256 amount, address _fromAccount, string action);
    event NotEnoughStakedFunds(address _fromAccount, string action);
    event FallbackData(bytes _data);

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
    
        require(_to != address(0));
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

    function changeTokenAddress(address _token) onlyOwner {

        sapienToken = _token;

    }
    
    function balanceOf(address _owner) public constant returns (uint256 balance) {
      return balances[_owner];
    }

    function interactWithSapien(string action, address _user) internal {

        require(msg.sender == _user);

        if (StringUtils.equal(action, "VOTE")) {

            balances[_user] = balances[_user].sub(forVote);

        } else if (StringUtils.equal(action, "COMMENT")) {

            balances[_user] = balances[_user].sub(forComment);

        } else if (StringUtils.equal(action, "POST")) {

            balances[_user] = balances[_user].sub(forPosting);

        } else {

            revert();

        }

    }

}