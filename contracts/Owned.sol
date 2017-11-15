pragma solidity ^0.4.15;

contract Owned {

    address private owner;
    address private newOwner;

    /// @notice The Constructor assigns the message sender to be `owner`
    function Owned() {
        owner = msg.sender;
    }

    function getOwner() public returns (address) {

        return owner;

    }

    function() {

        revert();

    }

    /// @notice `owner` can step down and assign some other address to this role
    /// @param _newOwner The address of the new owner. 0x0 can be used to create
    ///  an unowned neutral vault, however that cannot be undone
    function changeOwner(address _newOwner) {

        if (owner != msg.sender)
            revert();

        newOwner = _newOwner;

    }

    function acceptOwnership() {
        if (msg.sender == newOwner) {
            owner = newOwner;
            newOwner = 0x0000000000000000000000000000000000000000;
        }
    }
}