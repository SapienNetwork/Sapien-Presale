pragma solidity ^0.4.15;

import './Owned.sol';
import 'node_modules/zeppelin-solidity/contracts/token/BasicToken.sol';

contract SapienCoin is Owned {

    string public name = "SAPIEN COIN";
    string public symbol = "SPN";
    uint256 public decimals = 18;

    BasicToken private basicToken;

    event Mint(address indexed to, uint256 amount);

    function SapienCoin(address _basic) {

        basicToken = BasicToken(_basic);

    }

    function changeBasicToken(address _basic) onlyOwner {

        basicToken = BasicToken(_basic);

    }

    /**
     * @dev Function to mint new tokens, only the controller (initially the crowdsale contract) can call this
     * @param _to The address that will recieve the minted tokens.
     * @param _amount The amount of tokens to mint.
     * @return A boolean that indicates if the operation was successful.
     */
    function mint(address _to, uint256 _amount) onlyOwner returns (bool) {
        basicToken.increaseTotal(_amount);
        basicToken.addToBalance(_to, _amount);
        Mint(_to, _amount);
        return true;
    }

}