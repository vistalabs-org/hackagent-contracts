// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "forge-std/console2.sol"; // Ensure console2 is imported
import "../src/APIServicePayment.sol";
import "../src/ERC20Mock.sol"; // Import the ERC20Mock contract

contract DeployAPIServicePayment is Script {
    uint256 constant MOCK_TOKEN_MINT_AMOUNT = 1_000_000 * (10**18); // Mint 1 Million mock tokens

    function run() public returns (APIServicePayment) {
        // Get the deployer address (msg.sender within vm.startBroadcast() will be the EOA)
        // address deployer = msg.sender; // This will be set correctly inside the broadcast block

        // Start broadcasting transactions
        vm.startBroadcast(); // All subsequent state changes will be sent as transactions

        address deployer = msg.sender; // The EOA executing the script with --broadcast

        // 1. Deploy the ERC20Mock token
        console2.log("Deploying ERC20Mock token...");
        ERC20Mock mockToken = new ERC20Mock("Mock Payment Token", "MPT", 18);
        console2.log("ERC20Mock deployed to:", address(mockToken));

        // 2. Mint tokens to the deployer
        console2.log("Minting", MOCK_TOKEN_MINT_AMOUNT / (10**18), "MPT to deployer:", deployer);
        mockToken.mint(deployer, MOCK_TOKEN_MINT_AMOUNT);
        console2.log("Deployer MPT balance:", mockToken.balanceOf(deployer) / (10**18));

        // 3. Deploy the APIServicePayment contract with the new mock token's address
        address tokenAddress = address(mockToken);
        console2.log("Deploying APIServicePayment contract with Payment Token Address:", tokenAddress);
        APIServicePayment apiServicePayment = new APIServicePayment(tokenAddress);
        console2.log("APIServicePayment deployed to:", address(apiServicePayment));

        // Stop broadcasting
        vm.stopBroadcast();

        return apiServicePayment;
    }
} 