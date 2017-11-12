pragma solidity ^0.4.15;

import "contracts/Owned.sol";
import "contracts/StringUtils.sol";
import "node_modules/zeppelin-solidity/contracts/math/SafeMath.sol";

contract SapienToken {
  
    using SafeMath for uint256;

    mapping(address => uint256) balances;

    string public name = "SAPIEN COIN";
    string public symbol = "SPN";

    uint256 public decimals = 18;
    uint256 private canStake = 0;
    uint256 public totalSupply;

    Owned private owned;

    address private controller;

    address private stakeAddress;
    
    event FallbackData(bytes _data);
    event Transfer(address indexed from, address indexed to, uint value, bytes indexed data);

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

  /**
  * @dev transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
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

    function SapienToken(address _owned) {

      owned = Owned(_owned);

}

     function changeOwned(address _owned) {

        require(msg.sender == owned.getOwner());

        owned = Owned(_owned);

}

    function changeController(address _controller) {

        require(msg.sender == owned.getOwner());

        controller = _controller;

    }

     // Function to access name of token .
    function name() constant returns (string _name) {

        return name;

    }

  // Function to access symbol of token .
    function symbol() constant returns (string _symbol) {

        return symbol;

    }

  // Function to access decimals of token .
    function getDecimals() constant returns (uint256 _decimals) {

        return decimals;

    }

  // Function to access total supply of tokens .
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

  /**
  *@dev Disable staking in case of attack/vulnerability/etc
  */

  function disableTransferToContract() {

        require(msg.sender == owned.getOwner());

        canStake = 0;

        stakeAddress = 0x0000000000000000000000000000000000000000;
  
  }

  /**
  * @dev Gets the balance of the specified address.
  * @param _owner The address to query the the balance of.
  * @return An uint256 representing the amount owned by the passed address.
  */
  function balanceOf(address _owner) public constant returns (uint256 balance) {
      return balances[_owner];
  }

  function increaseTotal(uint256 _amount) public onlyOwner {

      totalSupply = totalSupply.add(_amount);

  }

  function addToBalance(address _to, uint256 _amount) public onlyOwner {

      balances[_to] = balances[_to].add(_amount);

  }

  //function that is called when transaction target is an address
  function transferToAddress(address _to, uint _value, bytes _data) private returns (bool success) {
    
    if (balanceOf(msg.sender) < _value) 
        revert();
    
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    Transfer(msg.sender, _to, _value, _data);
    return true;

  }

}

contract SapienStaking {

    using SafeMath for uint256;

    Owned private owned;

    address private sapienToken;

    uint256 public forComment = 1;
    uint256 public forPosting = 5;

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

        if (StringUtils.equal(action, "COMMENT")) {

            balances[_user] = balances[_user].sub(forComment);


        } else if (StringUtils.equal(action, "POST")) {

            balances[_user] = balances[_user].sub(forPosting);

        } else {

            revert();

        }

    }

}