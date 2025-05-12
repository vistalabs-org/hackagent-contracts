// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "@openzeppelin/contracts/mocks/token/ERC20Mock.sol"; // Import Mock ERC20
import "../src/APIServicePayment.sol";

contract APIServicePaymentTest is Test {
    APIServicePayment public apiServicePayment;
    ERC20Mock public paymentToken; // Mock ERC20 token instance
    address public owner;
    address public user1;
    address public user2;
    uint256 public constant INITIAL_TOKEN_BALANCE = 100_000 * 1e18; // Example: 100k tokens with 18 decimals
    uint256 public constant DEPOSIT_AMOUNT = 10 * 1e18; // Example: 100 tokens
    uint256 public constant API_COST_AMOUNT = 5 * 1e12; // Example: 50 tokens
    uint256 public constant WITHDRAW_AMOUNT = 5 * 1e15; // Example: 50 tokens

    event Deposit(address indexed user, uint256 amount);
    event Withdrawal(address indexed owner, uint256 amount, string service);
    event APICostUpdated(address indexed user, uint256 amount, string service);

    function setUp() public {
        owner = makeAddr("owner");
        user1 = makeAddr("user1");
        user2 = makeAddr("user2");

        // Deploy the mock ERC20 token
        paymentToken = new ERC20Mock(); // Name, Symbol, Decimals

        // Mint initial tokens for users
        paymentToken.mint(user1, INITIAL_TOKEN_BALANCE);
        paymentToken.mint(user2, INITIAL_TOKEN_BALANCE);

        // Deploy APIServicePayment contract with the mock token address
        vm.startPrank(owner);
        apiServicePayment = new APIServicePayment(address(paymentToken));
        vm.stopPrank();
    }

    function test_InitialState() public view {
        assertEq(apiServicePayment.owner(), owner);
        assertEq(apiServicePayment.totalDeposits(), 0);
        assertEq(address(apiServicePayment.paymentToken()), address(paymentToken));
        assertEq(apiServicePayment.getContractBalance(), 0); // Check initial token balance
    }

    // Helper function for approvals
    function _approveAndDeposit(address user, uint256 amount) internal {
         vm.startPrank(user);
         paymentToken.approve(address(apiServicePayment), amount);
         apiServicePayment.deposit(amount);
         vm.stopPrank();
    }

    function test_Deposit() public {
        uint256 depositAmount = DEPOSIT_AMOUNT;
        
        vm.startPrank(user1);
        // Approve first
        paymentToken.approve(address(apiServicePayment), depositAmount);
        // Emit event check
        vm.expectEmit(true, true, true, true);
        emit Deposit(user1, depositAmount);
        // Deposit
        apiServicePayment.deposit(depositAmount);
        vm.stopPrank();

        assertEq(apiServicePayment.getUserBalance(user1), depositAmount);
        assertEq(apiServicePayment.totalDeposits(), depositAmount);
        assertEq(paymentToken.balanceOf(address(apiServicePayment)), depositAmount); // Contract's token balance
        assertEq(paymentToken.balanceOf(user1), INITIAL_TOKEN_BALANCE - depositAmount); // User's remaining token balance
    }

     function test_Deposit_Fail_InsufficientBalance() public {
        uint256 depositAmount = INITIAL_TOKEN_BALANCE + 1 ether; // More than user has

        vm.startPrank(user1);
        paymentToken.approve(address(apiServicePayment), depositAmount); 
        // ERC20: transfer amount exceeds balance
        vm.expectRevert(); // Standard ERC20 revert message
        apiServicePayment.deposit(depositAmount);
        vm.stopPrank();
    }



    function test_UpdateAPICost() public {
        uint256 depositAmount = DEPOSIT_AMOUNT;
        uint256 apiCost = API_COST_AMOUNT;
        string memory service = "test-service";

        // First deposit
        _approveAndDeposit(user1, depositAmount);

        // Update API cost
        vm.startPrank(owner);
        vm.expectEmit(true, true, true, true);
        emit APICostUpdated(user1, apiCost, service);
        apiServicePayment.updateAPICost(user1, apiCost, service);
        vm.stopPrank();

        // Internal balances updated
        assertEq(apiServicePayment.getUserBalance(user1), depositAmount - apiCost);
        assertEq(apiServicePayment.getUserAPISpending(user1), apiCost);
        // Contract token balance unchanged by this operation
        assertEq(paymentToken.balanceOf(address(apiServicePayment)), depositAmount);
    }

    function test_UpdateAPICostInsufficientBalance() public {
        uint256 depositAmount = API_COST_AMOUNT / 2; // Deposit less than cost
        uint256 apiCost = API_COST_AMOUNT;

        // First deposit
         _approveAndDeposit(user1, depositAmount);

        vm.startPrank(owner);
        vm.expectRevert(APIServicePayment.InsufficientUserBalance.selector);
        apiServicePayment.updateAPICost(user1, apiCost, "test-service");
        vm.stopPrank();
    }

    function test_WithdrawForService() public {
        uint256 depositAmount = DEPOSIT_AMOUNT;
        uint256 withdrawAmount = WITHDRAW_AMOUNT;
        string memory service = "test-service";

        // First deposit
        _approveAndDeposit(user1, depositAmount);

        uint256 ownerInitialBalance = paymentToken.balanceOf(owner);
        uint256 contractInitialBalance = paymentToken.balanceOf(address(apiServicePayment));

        // Withdraw
        vm.startPrank(owner);
        vm.expectEmit(true, true, true, true);
        emit Withdrawal(owner, withdrawAmount, service);
        apiServicePayment.withdrawForService(withdrawAmount, service);
        vm.stopPrank();

        assertEq(paymentToken.balanceOf(address(apiServicePayment)), contractInitialBalance - withdrawAmount);
        assertEq(paymentToken.balanceOf(owner), ownerInitialBalance + withdrawAmount);
        assertEq(apiServicePayment.getContractBalance(), contractInitialBalance - withdrawAmount); // Check via getter too
    }

    function test_WithdrawForServiceInsufficientBalance() public {
        uint256 depositAmount = WITHDRAW_AMOUNT / 2; // Deposit less than withdraw amount
        uint256 withdrawAmount = WITHDRAW_AMOUNT;

        // First deposit
        _approveAndDeposit(user1, depositAmount);

        vm.startPrank(owner);
        vm.expectRevert(APIServicePayment.InsufficientBalance.selector);
        apiServicePayment.withdrawForService(withdrawAmount, "test-service");
        vm.stopPrank();
    }

    // --- Test Getters ---
    function test_Getters() public {
        uint256 depositAmount = DEPOSIT_AMOUNT;
        uint256 apiCost = API_COST_AMOUNT;

        // Check initial spending for user 1 (caller) and user 2 (specific)
        vm.startPrank(user1);
        assertEq(apiServicePayment.getAPISpending(), 0);
        vm.stopPrank();
        assertEq(apiServicePayment.getUserAPISpending(user2), 0);


        // Deposit
        _approveAndDeposit(user1, depositAmount);

        // Check balances
        vm.startPrank(user1);
        assertEq(apiServicePayment.getBalance(), depositAmount);
        vm.stopPrank();
        assertEq(apiServicePayment.getUserBalance(user1), depositAmount);
        assertEq(apiServicePayment.getUserBalance(user2), 0); // User 2 has no balance

        // Update cost
        vm.startPrank(owner);
        apiServicePayment.updateAPICost(user1, apiCost, "test-service");
        vm.stopPrank();

        // Check spending
        vm.startPrank(user1);
        assertEq(apiServicePayment.getAPISpending(), apiCost);
        vm.stopPrank();
        assertEq(apiServicePayment.getUserAPISpending(user1), apiCost);
        assertEq(apiServicePayment.getUserAPISpending(user2), 0);

        // Check remaining balance
        assertEq(apiServicePayment.getUserBalance(user1), depositAmount - apiCost);

         // Check contract balance
        assertEq(apiServicePayment.getContractBalance(), depositAmount);
    }

    // Note: test_Receive was removed as the receive() function was removed.
}
