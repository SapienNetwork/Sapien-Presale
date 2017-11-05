pragma solidity ^0.4.15;

import "./Owned.sol";
import "node_modules/zeppelin-solidity/contracts/token/SapienToken.sol";

contract TokenController {

    SapienToken private sapienToken;
    Owned private owned;

    address private crowdsale;

    event Mint(address indexed to, uint256 amount);

    /// @dev `owner` is the only address that can call a function with this
    /// modifier
    modifier onlyOwner() {
        require(msg.sender == owned.getOwner() || crowdsale == msg.sender);
        _;
    }

    function TokenController(address _sapien, address _owned) {

        sapienToken = SapienToken(_sapien);
        owned = Owned(_owned);
    
    }

    function changeBasicToken(address _sapien) onlyOwner {

        sapienToken = SapienToken(_sapien);

    }

    function changeOwned(address _owned) onlyOwner {

        owned = Owned(_owned);

    }

    function changeCrowdsale(address _crowdsale) onlyOwner {

        crowdsale = _crowdsale;

    }

    /**
     * @dev Function to mint new tokens, only the controller (initially the crowdsale contract) can call this
     * @param _to The address that will recieve the minted tokens.
     * @param _amount The amount of tokens to mint.
     * @return A boolean that indicates if the operation was successful.
     */
    function mint(address _to, uint256 _amount) onlyOwner returns (bool) {
        sapienToken.increaseTotal(_amount);
        sapienToken.addToBalance(_to, _amount);
        Mint(_to, _amount);
        return true;
    }

}