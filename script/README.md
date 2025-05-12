# APIServicePayment Contract Deployment

This directory contains the deployment script for the APIServicePayment contract.

## Prerequisites

1. Make sure you have Foundry installed
2. Set up your environment variables in a `.env` file:
   ```
   ETHEREUM_RPC_URL=your_mainnet_rpc_url
   GOERLI_RPC_URL=your_goerli_rpc_url
   SEPOLIA_RPC_URL=your_sepolia_rpc_url
   PRIVATE_KEY=your_deployer_private_key
   ETHERSCAN_API_KEY=your_etherscan_api_key
   ```

## Deployment Commands

### Local Network
```bash
forge script script/DeployAPIServicePayment.s.sol:DeployAPIServicePayment --fork-url http://localhost:8545 --broadcast
```

### Goerli Testnet
```bash
forge script script/DeployAPIServicePayment.s.sol:DeployAPIServicePayment --rpc-url $GOERLI_RPC_URL --broadcast --verify -vvvv
```

### Mainnet
```bash
forge script script/DeployAPIServicePayment.s.sol:DeployAPIServicePayment --rpc-url $ETHEREUM_RPC_URL --broadcast --verify -vvvv
```

## Verification

The deployment script includes automatic contract verification on Etherscan. Make sure to:
1. Set your `ETHERSCAN_API_KEY` in the `.env` file
2. Use the `--verify` flag when deploying

## Post-Deployment

After deployment:
1. Save the deployed contract address
2. Verify the contract on Etherscan
3. Test the contract functionality:
   - Deposit funds
   - Update API costs
   - Check balances and spending

## Security Notes

- Never commit your `.env` file
- Keep your private keys secure
- Test thoroughly on testnets before mainnet deployment 