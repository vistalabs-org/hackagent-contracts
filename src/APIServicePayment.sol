// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract APIServicePayment is Ownable {
    IERC20 public immutable paymentToken;

    mapping(address => uint256) public balances;
    mapping(address => uint256) public apiSpending;
    uint256 public totalDeposits;
    
    error ZeroAmount();
    error InsufficientBalance();
    error TransferFailed();
    error InsufficientUserBalance();
    error TransferFromFailed();
    
    event Deposit(address indexed user, uint256 amount);
    event Withdrawal(address indexed owner, uint256 amount, string service);
    event APICostUpdated(address indexed user, uint256 amount, string service);
    
    constructor(address _tokenAddress) Ownable(msg.sender) {
        if (_tokenAddress == address(0)) revert ZeroAmount();
        paymentToken = IERC20(_tokenAddress);
    }
    
    function deposit(uint256 amount) external {
        if (amount == 0) revert ZeroAmount();
        
        uint256 initialBalance = paymentToken.balanceOf(address(this));
        bool success = paymentToken.transferFrom(msg.sender, address(this), amount);
        if (!success) revert TransferFromFailed();
        if (paymentToken.balanceOf(address(this)) <= initialBalance) revert TransferFromFailed();

        balances[msg.sender] += amount;
        totalDeposits += amount;
        emit Deposit(msg.sender, amount);
    }
    
    function updateAPICost(address user, uint256 amount, string memory service) external onlyOwner {
        if (amount == 0) revert ZeroAmount();
        if (balances[user] < amount) revert InsufficientUserBalance();
        
        balances[user] -= amount;
        apiSpending[user] += amount;
        
        emit APICostUpdated(user, amount, service);
    }
    
    function withdrawForService(uint256 amount, string memory service) external onlyOwner {
        if (amount == 0) revert ZeroAmount();
        if (paymentToken.balanceOf(address(this)) < amount) revert InsufficientBalance();
        
        bool success = paymentToken.transfer(owner(), amount);
        if (!success) revert TransferFailed();
        
        emit Withdrawal(owner(), amount, service);
    }
    
    function getBalance() external view returns (uint256) {
        return balances[msg.sender];
    }
    
    function getAPISpending() external view returns (uint256) {
        return apiSpending[msg.sender];
    }
    
    function getUserBalance(address user) public view returns (uint256) {
        return balances[user];
    }
    
    function getUserAPISpending(address user) public view returns (uint256) {
        return apiSpending[user];
    }
    
    function getContractBalance() external view returns (uint256) {
        return paymentToken.balanceOf(address(this));
    }
} 