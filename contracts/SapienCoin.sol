pragma solidity ^0.4.13;

import "./Owned.sol";
import "zeppelin/contracts/token/MintableToken.sol";

contract SapienCoin is Owned, MintableToken {

    string public name = "SAPIEN COIN";
    string public symbol = "SPN";
    uint256 public decimals = 18;

}
