pragma solidity ^0.4.13;

import "./Controlled.sol";
import "zeppelin/contracts/token/StandardToken.sol";

contract SapienCoin is Controlled, StandardToken {

    string public name = "SAPIEN COIN";
    string public symbol = "SPN";
    uint256 public decimals = 18;

    event Mint(address indexed to, uint256 amount);

    /**
     * @dev Function to mint new tokens, only the controller (initially the crowdsale contract) can call this
     * @param _to The address that will recieve the minted tokens.
     * @param _amount The amount of tokens to mint.
     * @return A boolean that indicates if the operation was successful.
     */
    function mint(address _to, uint256 _amount) onlyController returns (bool) {
        totalSupply = totalSupply.add(_amount);
        balances[_to] = balances[_to].add(_amount);
        Mint(_to, _amount);
        return true;
    }

}
