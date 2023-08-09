// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract MultiSigWallet{

    address[] public owners;
    uint256 public numConfirmationsRequired;

    struct Transaction {
        address to;
        uint256 value;
        bool executed;
        mapping(address => bool) isConfirmed;
    }

    Transaction[] public transactions;
    event Deposit(address indexed sender, uint256 value);
    event SubmitTransaction( address indexed owner, uint256 indexed txIndex, address indexed to, uint256 value);
    event ConfirmTransaction(address indexed owner, uint256 indexed txIndex);
    event ExecuteTransaction(address indexed owner, uint256 indexed txIndex);
    event RevokeConfirmation(address indexed owner, uint256 indexed txIndex);

    //判断调用地址是否在owners里面
    modifier onlyOwner() {
        bool isOwner = false;
        for (uint256 i = 0; i < owners.length; i++) {
            if (owners[i] == msg.sender) {
                isOwner = true;
                break;
            }
        }
        require(isOwner, "Only owners can call this function.");
        _;
    }

    constructor(address[] memory _owners, uint256 _numConfirmationsRequired) {
        require(_owners.length > 0, "Owners required.");
        require( _numConfirmationsRequired > 0 && _numConfirmationsRequired <= _owners.length,
            "Invalid number of required confirmations."
        );
        owners = _owners;
        numConfirmationsRequired = _numConfirmationsRequired;
    }

    receive() external payable {
        emit Deposit(msg.sender, msg.value);
    }

    function submitTransaction(address _to, uint256 _value) public onlyOwner {
        uint256 txIndex = transactions.length;
        /*
        transactions.push(
            Transaction({to: _to, value: _value, executed: false})
        );
        */
        Transaction storage newTransaction = transactions.push();
        newTransaction.to = _to;
        newTransaction.value = _value;
        newTransaction.executed = false;

        emit SubmitTransaction(msg.sender, txIndex, _to, _value);
    }

    function confirmTransaction(uint256 _txIndex) public onlyOwner {
        Transaction storage transaction = transactions[_txIndex];
        require(transaction.executed == false, "Transaction already executed.");
        require( transaction.isConfirmed[msg.sender] == false,"Transaction already confirmed by owner." );
        transaction.isConfirmed[msg.sender] = true;
        emit ConfirmTransaction(msg.sender, _txIndex);
        //executeTransaction(_txIndex);
    }


    function executeTransaction(uint256 _txIndex) public onlyOwner {
        Transaction storage transaction = transactions[_txIndex];
        require(transaction.executed == false, "Transaction already executed.");
        uint256 numConfirmations = 0;
        for (uint256 i = 0; i < owners.length; i++) {
            if (transaction.isConfirmed[owners[i]]) {
                numConfirmations += 1;
            }
        }
        require( numConfirmations >= numConfirmationsRequired, "Not enough confirmations.");
        transaction.executed = true;
        (bool success, ) = transaction.to.call{value: transaction.value}("");
        require(success, "Transaction failed.");
        emit ExecuteTransaction(msg.sender, _txIndex);
    }

    function revokeConfirmation(uint256 _txIndex) public onlyOwner {
        Transaction storage transaction = transactions[_txIndex];
        require(transaction.executed == false, "Transaction already executed.");
        require(transaction.isConfirmed[msg.sender] == true, "Transaction not confirmed by owner." );
        transaction.isConfirmed[msg.sender] = false;
        emit RevokeConfirmation(msg.sender, _txIndex);
    }

    function getOwners() public view returns (address[] memory) {
        return owners;
    }

    function getTransactionCount() public view returns (uint256) {
        return transactions.length;
    }

    function getTransaction(uint256 _txIndex) public view returns (address to, uint256 value, bool executed)
    {
        Transaction storage transaction = transactions[_txIndex];
        return (transaction.to, transaction.value, transaction.executed);
    }

    function isConfirmed(uint256 _txIndex, address _owner) public view returns (bool)
    {
        Transaction storage transaction = transactions[_txIndex];
        return transaction.isConfirmed[_owner];
    }





}