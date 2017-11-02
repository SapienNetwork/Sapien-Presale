pragma solidity ^0.4.13;

import './Ownable.sol';
import 'node_modules/zeppelin-solidity/contracts/token/StandardToken.sol';
import 'node_modules/zeppelin-solidity/contracts/math/SafeMath.sol';

contract SapienCoin is Ownable, StandardToken {

    using SafeMath for uint256;

    string public name = "SAPIEN COIN";
    string public symbol = "SPN";

    uint256 public decimals = 18;
    uint256 private canStake = 0;

    SapienStaking public staking;

    event Mint(address indexed to, uint256 amount);

    /**
     * @dev Function to mint new tokens, only the controller (initially the crowdsale contract) can call this
     * @param _to The address that will recieve the minted tokens.
     * @param _amount The amount of tokens to mint.
     * @return A boolean that indicates if the operation was successful.
     */
    function mint(address _to, uint256 _amount) onlyOwner returns (bool) {
        totalSupply = totalSupply.add(_amount);
        balances[_to] = balances[_to].add(_amount);
        Mint(_to, _amount);
        return true;
    }

    function initStaking(address _where) onlyOwner {

        staking = new SapienStaking(_where);

        canStake = 1;

    }

    function stakeAmount(uint256 amount) returns (bool success) {

        require(canStake == 1);

        require(balances[msg.sender].sub(amount) >= 0);

        balances[msg.sender].sub(amount);

        staking.addStakeFunds(amount);

    }

    function urgentWithdrawFromUser(address _from, address _to) onlyOwner returns (bool success) {

        require(canStake == 1);

        uint256 amount = balances[_from];

        balances[_from].sub(balances[_from]);

        staking.urgentWithdrawFromUser(_from);

        balances[_to].mint(amount);

        return true;

    }

}
