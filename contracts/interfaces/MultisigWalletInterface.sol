pragma solidity ^0.4.18;

contract MultisigWalletInterface {

    event Confirmation(address indexed sender, uint indexed transactionId);
    event Revocation(address indexed sender, uint indexed transactionId);
    event Submission(uint indexed transactionId);
    event Execution(uint indexed transactionId);
    event ExecutionFailure(uint indexed transactionId);
    event Deposit(address indexed sender, uint value);
    event OwnerAddition(address indexed owner);
    event OwnerRemoval(address indexed owner);
    event RequirementChange(uint required);

    /// @dev Fallback function allows to deposit ether.

    function() payable;

    /// @dev Allows to add a new owner. Transaction has to be sent by wallet.
    /// @param owner Address of new owner.

    function addOwner(address owner) public;

    /// @dev Allows to remove an owner. Transaction has to be sent by wallet.
    /// @param owner Address of owner.

    function removeOwner(address owner) public;

    /// @dev Allows to replace an owner with a new owner. Transaction has to be sent by wallet.
    /// @param owner Address of owner to be replaced.
    /// @param owner Address of new owner.

    function replaceOwner(address owner, address newOwner) public;

    /// @dev Allows to change the number of required confirmations. Transaction has to be sent by wallet.
    /// @param _required Number of required confirmations.

    function changeRequirement(uint _required) public;

    /// @dev Allows an owner to submit and confirm a transaction.
    /// @param destination Transaction target address.
    /// @param value Transaction ether value.
    /// @param data Transaction data payload.
    /// @return Returns transaction ID.

    function submitTransaction(address destination, uint value, bytes data) 
        public returns (uint transactionId);

    /// @dev Allows an owner to confirm a transaction.
    /// @param transactionId Transaction ID.

    function confirmTransaction(uint transactionId) public;

     /// @dev Allows an owner to revoke a confirmation for a transaction.
    /// @param transactionId Transaction ID.

    function revokeConfirmation(uint transactionId) public;

    /// @dev Allows anyone to execute a confirmed transaction.
    /// @param transactionId Transaction ID.

    function executeTransaction(uint transactionId) public;

    /// @dev Returns the confirmation status of a transaction.
    /// @param transactionId Transaction ID.
    /// @return Confirmation status.

    function isConfirmed(uint transactionId) public constant returns (bool);

     /*
     * Internal functions
     */
    /// @dev Adds a new transaction to the transaction mapping, if transaction does not exist yet.
    /// @param destination Transaction target address.
    /// @param value Transaction ether value.
    /// @param data Transaction data payload.
    /// @return Returns transaction ID.

    function addTransaction(address destination, uint value, bytes data) 
        internal returns (uint transactionId);

     /*
     * Web3 call functions
     */
    /// @dev Returns number of confirmations of a transaction.
    /// @param transactionId Transaction ID.
    /// @return Number of confirmations.

    function getConfirmationCount(uint transactionId) public constant returns (uint count);

    /// @dev Returns total number of transactions after filers are applied.
    /// @param pending Include pending transactions.
    /// @param executed Include executed transactions.
    /// @return Total number of transactions after filters are applied.

    function getTransactionCount(bool pending, bool executed)
        public constant returns (uint count);

    /// @dev Returns list of owners.
    /// @return List of owner addresses.

    function getOwners()
        public constant returns (address[]);

    /// @dev Returns array with owner addresses, which confirmed transaction.
    /// @param transactionId Transaction ID.
    /// @return Returns array of owner addresses.

    function getConfirmations(uint transactionId)
        public constant returns (address[] _confirmations);

    /// @dev Returns list of transaction IDs in defined range.
    /// @param from Index start position of transaction array.
    /// @param to Index end position of transaction array.
    /// @param pending Include pending transactions.
    /// @param executed Include executed transactions.
    /// @return Returns array of transaction IDs.

    function getTransactionIds(uint from, uint to, bool pending, bool executed)
        public constant returns (uint[] _transactionIds);

}