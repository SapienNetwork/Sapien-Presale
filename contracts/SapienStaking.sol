pragma solidity ^0.4.15;

import "./Owned.sol";
import "./ERC223.sol";
import "node_modules/zeppelin-solidity/contracts/math/SafeMath.sol";
import "node_modules/zeppelin-solidity/contracts/token/SapienToken.sol";

contract SapienStaking is ERC223 {

    using SafeMath for uint256;

    Owned private owned;

    address private sapienToken;
    address private sapienTokenAddress;

    string public name = "SAPIEN COIN";
    string public symbol = "SPN";

    uint256 public decimals = 18;

    mapping (address => uint256) balances;

     struct TKN {
        address sender;
        uint value;
        bytes data;
        bytes4 sig;
    }

     modifier onlyOwner() {
        require(msg.sender == owned.getOwner());
        _;
    }
    
    event StakedForAction(uint256 amount, address _fromAccount, string action);
    event NotEnoughStakedFunds(address _fromAccount, string action);

    function tokenFallback(address _from, uint _value, bytes _data) {

      TKN tkn;

      tkn.sender = _from;
      tkn.value = _value;
      tkn.data = _data;

      uint32 u = uint32(_data[3]) + (uint32(_data[2]) << 8) + (uint32(_data[1]) << 16) + (uint32(_data[0]) << 24);
      tkn.sig = bytes4(u);

      balances[tkn.sender] = balances[tkn.sender].add(tkn.value);

      totalSupply = totalSupply.add(_value);
    
    }

    function SapienStaking() {

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
    function decimals() constant returns (uint256 _decimals) {

        return decimals;

    }

  // Function to access total supply of tokens .
    function totalSupply() constant returns (uint256) {

        return totalSupply;

    }

    function changeTokenAddress(address _token) onlyOwner {

        sapienTokenAddress = _token;

    }

    /**
  * @dev transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value, string _custom_fallback) public returns (bool) {
    
      require(_to != address(0));
      require(_value <= balances[msg.sender]);

      if(_to == sapienTokenAddress) {

        balances[msg.sender] = balances[msg.sender].sub(_value);

        SapienToken receiver = SapienToken(_to);
        receiver.call.value(0)(bytes4(keccak256(_custom_fallback)), msg.sender, _value, _data);

        totalSupply = totalSupply.sub(_value);

        Transfer(msg.sender, _to, _value, _data);
        
        return true;

    } else if (!isContract(_to)) {

        return transferToAddress(_to, _value, _data);

    }

  }

    function isContract(address _addr) private returns (bool is_contract) {
      
      uint length;

      assembly {
            //retrieve the size of the code on target address, this needs assembly
            length := extcodesize(_addr)
      }

      return (length > 0);
      
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