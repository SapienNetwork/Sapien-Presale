pragma solidity ^0.4.18;

import "contracts/Owned.sol";
import "contracts/SapienToken.sol";

contract TokenController {

    ERC223 private sapienToken;
    Owned private owned;

    address private crowdsale;

    /// @dev `owner` is the only address that can call a function with this
    /// modifier
    modifier acceptedOwners() {
        require(msg.sender == owned.getOwner() || crowdsale == msg.sender);
        _;
    }

    modifier onlyOwner() {

        require(msg.sender == owned.getOwner());
        _;

    }

    function TokenController(address _sapien, address _owned) {

        sapienToken = ERC223(_sapien);
        owned = Owned(_owned);
    
    }

    function() payable {

        revert();

    }

    function changeBasicToken(address _sapien) public onlyOwner {

        sapienToken = ERC223(_sapien);

    }

    function changeOwned(address _owned) public onlyOwner {

        owned = Owned(_owned);

    }

    function changeCrowdsale(address _crowdsale) public onlyOwner {

        crowdsale = _crowdsale;

    }

    /**
     * @dev Function to mint new tokens, only the controller (initially the crowdsale contract) can call this
     * @param _to The address that will recieve the minted tokens.
     * @param _amount The amount of tokens to mint.
     * @return A boolean that indicates if the operation was successful.
     */
    function allocateTokens(address _to, uint256 _amount) public acceptedOwners returns (bool) {
        sapienToken.increaseCirculation(_amount);
        sapienToken.addToBalance(_to, _amount);
        Allocate(_to, _amount);
        return true;
    }

}