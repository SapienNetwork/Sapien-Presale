pragma solidity ^0.4.18;

/// @author Stefan Ionescu - <codrinionescu@yahoo.com>

import "contracts/Owned.sol";
import "contracts/SapienToken.sol";
import "contracts/interfaces/SapienTokenInterface.sol";
import "contracts/interfaces/TokenControllerInterface.sol";

contract TokenController is TokenControllerInterface {

    SapienTokenInterface private sapienToken;
    Owned private owned;

    address private crowdsale;

    modifier acceptedOwners() {
        require(msg.sender == owned.getOwner() || crowdsale == msg.sender);
        _;
    }

    modifier onlyOwner() {

        require(msg.sender == owned.getOwner());
        _;

    }

    function TokenController(address _sapien, address _owned) {

        sapienToken = SapienTokenInterface(_sapien);
        owned = Owned(_owned);
    
    }

    function() payable {

        revert();

    }

    function changeSPNToken(address _sapien) public onlyOwner {

        sapienToken = SapienTokenInterface(_sapien);

    }

    function changeOwned(address _owned) public onlyOwner {

        owned = Owned(_owned);

    }

    function changeCrowdsale(address _crowdsale) public onlyOwner {

        crowdsale = _crowdsale;

    }

    function allocateTokens(address _to, uint256 _amount) public acceptedOwners returns (bool) {
        sapienToken.increaseCirculation(_amount);
        sapienToken.addToBalance(_to, _amount);
        Allocate(_to, _amount);
        return true;
    }

}