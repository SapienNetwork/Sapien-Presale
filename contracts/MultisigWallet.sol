pragma solidity ^0.4.18;

import "contracts/interfaces/MultisigWalletInterface.sol";

/// @title Multisignature wallet - Allows multiple parties to agree on transactions before execution.
/// @author Stefan George - <stefan.george@consensys.net>

contract MultiSigWallet is MultisigWalletInterface {

    modifier onlyWallet() {
        if (msg.sender != address(this))
            throw;
        _;
    }

    modifier ownerDoesNotExist(address owner) {
        if (isOwner[owner])
            throw;
        _;
    }

    modifier ownerExists(address owner) {
        if (!isOwner[owner])
            throw;
        _;
    }

    modifier transactionExists(uint transactionId) {
        if (transactions[transactionId].destination == 0)
            throw;
        _;
    }

    modifier confirmed(uint transactionId, address owner) {
        if (!confirmations[transactionId][owner])
            throw;
        _;
    }

    modifier notConfirmed(uint transactionId, address owner) {
        if (confirmations[transactionId][owner])
            throw;
        _;
    }

    modifier notExecuted(uint transactionId) {
        if (transactions[transactionId].executed)
            throw;
        _;
    }

    modifier notNull(address _address) {
        if (_address == 0)
            throw;
        _;
    }

    modifier validRequirement(uint ownerCount, uint _required) {
        if ( ownerCount > MAX_OWNER_COUNT
            || _required > ownerCount
            || _required == 0
            || ownerCount == 0)
            throw;
        _;
    }

    function() payable {
        
        if (msg.value > 0) {

            Deposit(msg.sender, msg.value);

        }
            
    }

    /*
     * Public functions
     */
    /// @dev Contract constructor sets initial owners and required number of confirmations.
    /// @param _owners List of initial owners.
    /// @param _required Number of required confirmations.

    function MultiSigWallet(address[] _owners, uint _required) 
        public validRequirement(_owners.length, _required) {
        
        for (uint i=0; i<_owners.length; i++) {

            if (isOwner[_owners[i]] || _owners[i] == 0)
                revert();

            isOwner[_owners[i]] = true;

        }

        owners = _owners;
        required = _required;

    }

    
    function addOwner(address owner)
        public onlyWallet ownerDoesNotExist(owner)
        notNull(owner)
        validRequirement(owners.length + 1, required) {

        isOwner[owner] = true;
        owners.push(owner);
        OwnerAddition(owner);
    
    }

    function removeOwner(address owner)
        public onlyWallet ownerExists(owner) {

        isOwner[owner] = false;

        for (uint i=0; i<owners.length - 1; i++) {

            if (owners[i] == owner) {
                owners[i] = owners[owners.length - 1];
                break;
            }

        }
            
        owners.length -= 1;

        if (required > owners.length)
            changeRequirement(owners.length);

        OwnerRemoval(owner);

    }

    function replaceOwner(address owner, address newOwner) public
        onlyWallet ownerExists(owner) ownerDoesNotExist(newOwner) {

        for (uint i=0; i<owners.length; i++) {

            if (owners[i] == owner) {

                owners[i] = newOwner;
                break;

            }

        }
            
        isOwner[owner] = false;
        isOwner[newOwner] = true;
        OwnerRemoval(owner);
        OwnerAddition(newOwner);

    }

    function changeRequirement(uint _required)
        public
        onlyWallet
        validRequirement(owners.length, _required)
    {
        required = _required;
        RequirementChange(_required);
    }

    function submitTransaction(address destination, uint value, bytes data)
        public
        returns (uint transactionId)
    {
        transactionId = addTransaction(destination, value, data);
        confirmTransaction(transactionId);
    }

    function confirmTransaction(uint transactionId)
        public
        ownerExists(msg.sender)
        transactionExists(transactionId)
        notConfirmed(transactionId, msg.sender)
    {
        confirmations[transactionId][msg.sender] = true;
        Confirmation(msg.sender, transactionId);
        executeTransaction(transactionId);
    }

    function revokeConfirmation(uint transactionId)
        public
        ownerExists(msg.sender)
        confirmed(transactionId, msg.sender)
        notExecuted(transactionId)
    {
        confirmations[transactionId][msg.sender] = false;
        Revocation(msg.sender, transactionId);
    }

    function executeTransaction(uint transactionId)
        public
        notExecuted(transactionId) {

        if (isConfirmed(transactionId)) {

            Transaction tx = transactions[transactionId];
            tx.executed = true;

            if (tx.destination.call.value(tx.value)(tx.data))
                Execution(transactionId);

            else {

                ExecutionFailure(transactionId);
                tx.executed = false;

            }
        }
    }

    function isConfirmed(uint transactionId)
        public constant returns (bool) {
        
        uint count = 0;

        for (uint i=0; i<owners.length; i++) {

            if (confirmations[transactionId][owners[i]])
                count += 1;

            if (count == required)
                return true;

        }

    }

    function addTransaction(address destination, uint value, bytes data)
        internal notNull(destination) returns (uint transactionId) {

        transactionId = transactionCount;

        transactions[transactionId] = Transaction({
            destination: destination,
            value: value,
            data: data,
            executed: false
        });

        transactionCount += 1;
        Submission(transactionId);

    }

    function getConfirmationCount(uint transactionId)
        public constant returns (uint count) {

        for (uint i=0; i<owners.length; i++) {

            if (confirmations[transactionId][owners[i]])
                count += 1;

        }
            
    }

    function getTransactionCount(bool pending, bool executed)
        public constant returns (uint count) {

        for (uint i=0; i<transactionCount; i++) {

            if (pending && !transactions[i].executed
                || executed && transactions[i].executed)
                count += 1;

        }
            
    }

    function getOwners() public constant returns (address[]) {
        
        return owners;
    
    }

    function getConfirmations(uint transactionId)
        public
        constant
        returns (address[] _confirmations) {

        address[] memory confirmationsTemp = new address[](owners.length);
        uint count = 0;
        uint i;

        for (i=0; i<owners.length; i++) {

             if (confirmations[transactionId][owners[i]]) {
                confirmationsTemp[count] = owners[i];
                count += 1;
            }

        }
           
        _confirmations = new address[](count);

        for (i=0; i<count; i++)
            _confirmations[i] = confirmationsTemp[i];

    }

    function getTransactionIds(uint from, uint to, bool pending, bool executed)
        public
        constant
        returns (uint[] _transactionIds) {

        uint[] memory transactionIdsTemp = new uint[](transactionCount);
        uint count = 0;
        uint i;

        for (i=0; i<transactionCount; i++) {

            if (pending && !transactions[i].executed
                || executed && transactions[i].executed) {

                transactionIdsTemp[count] = i;
                count += 1;

            }

        }
            
        _transactionIds = new uint[](to - from);

        for (i=from; i<to; i++)
            _transactionIds[i - from] = transactionIdsTemp[i];
            
    }
}