## Foundry

**Foundry is a blazing fast, portable and modular toolkit for Ethereum application development written in Rust.**

```text
== Logs ==
  Deploying ERC20Mock token...
  ERC20Mock deployed to: 0x871F75C1cE8776768E92A81604eDec5716137c81
  Minting 1000000 MPT to deployer: 0x6786B1148E0377BEFe86fF46cc073dE96B987FE4
  Deployer MPT balance: 1000000
  Deploying APIServicePayment contract with Payment Token Address: 0x871F75C1cE8776768E92A81604eDec5716137c81
  APIServicePayment deployed to: 0xe87B112662F877B2C947B309233D025F7EAD3c4D
```

Foundry consists of:

-   **Forge**: Ethereum testing framework (like Truffle, Hardhat and DappTools).
-   **Cast**: Swiss army knife for interacting with EVM smart contracts, sending transactions and getting chain data.
-   **Anvil**: Local Ethereum node, akin to Ganache, Hardhat Network.
-   **Chisel**: Fast, utilitarian, and verbose solidity REPL.

## Documentation

https://book.getfoundry.sh/

## Usage

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

### Format

```shell
$ forge fmt
```

### Gas Snapshots

```shell
$ forge snapshot
```

### Anvil

```shell
$ anvil
```

### Deploy

```shell
$ forge script script/Counter.s.sol:CounterScript --rpc-url <your_rpc_url> --private-key <your_private_key>
```

### Cast

```shell
$ cast <subcommand>
```

### Help

```shell
$ forge --help
$ anvil --help
$ cast --help
```
