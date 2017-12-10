pragma solidity ^0.4.18;

import "contracts/Owned.sol";
import "contracts/libraries/SafeMath.sol";

contract SPNStorage {

    using SafeMath for uint256;

    mapping(address => uint256) balances;

    mapping(address => uint256) allowedContracts;

    mapping(address => uint256) stakedAmounts;

    Owned private owned;

    modifier onlyAllowedContracts {

        require(allowedContracts[msg.sender] == 1);
        _;

    }

    modifier onlyOwner {

        require(msg.sender == owned.getOwner());
        _;

    }

    function SPNStorage(address _owned) {

        owned = Owned(_owned);

    }

    function changeOwner(address _owned) onlyOwner {

        owned = Owned(_owned);

    }

    function addContract(address _contract) onlyOwner {

        allowedContracts[_contract] = 1;

    }

    function deleteContract(address _contract) onlyOwner {

        require(allowedContracts[_contract] == 1);

        allowedContracts[_contract] = 0;

    }

    function getUnstakedBalance(address _who) public constant onlyAllowedContracts returns (uint256) {

        return balances[_who];

    }

    function getStakedBalance(address _who) public constant onlyAllowedContracts returns (uint256) {

        return stakedAmounts[_who];

    }

    function increaseUnstakedSPNBalance(address _who, uint256 _amount) onlyAllowedContracts {

        require(_amount > 0);
        require(_who != address(0));

        balances[_who] = balances[_who].add(_amount);

    }

    function decreaseUnstakedSPNBalance(address _who, uint256 _amount) onlyAllowedContracts {

        require(_amount > 0);
        require(_who != address(0));
        require(balances[_who] >= _amount);

        balances[_who] = balances[_who].sub(_amount);

    }

    function increaseStakedSPNBalance(address _who, uint256 _amount) onlyAllowedContracts {

        require(_amount > 0);
        require(_who != address(0));
        
        stakedAmounts[_who] = stakedAmounts[_who].add(_amount);

    }

    function decreaseStakedSPNBalance(address _who, uint256 _amount) onlyAllowedContracts {

        require(_amount > 0);
        require(_who != address(0));
        require(stakedAmounts[_who] >= _amount);
        
        stakedAmounts[_who] = stakedAmounts[_who].sub(_amount);

    }

}