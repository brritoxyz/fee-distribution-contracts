# Brrito Fee Distribution Contracts

A series of contracts that handle accounting and distribution of Brrito app fees to BRR stakers. Built on [Fei Protocol's Flywheel V2](https://github.com/fei-protocol/flywheel-v2).

## Installation

The steps below assume that the code repo has already been cloned and the reader has navigated to the root of the project directory.

1. Install Foundry: https://book.getfoundry.sh/.
2. Run `forge i` to install project dependencies.
3. Run `forge test --rpc-url https://mainnet.base.org` to compile contracts and run tests.

## Contract Deployments

| Chain ID         | Chain             | Contract | Contract Address                           | Deployment Tx |
| :--------------- | :---------------- | :----------------------------------------- | :----------------------------------------- | :------------ |
| 8453                | Base  | FlywheelCore.sol | 0x771F3Ec0BFCDdf107E9fD90e1B45e9d6001C65A5 | [BaseScan](https://basescan.org/tx/0x1db05768147e8ba896997e0a63d018d31245dc2a81b8a5a1a71da6e645795083) |
| 8453                | Base  | DynamicRewards.sol | 0xC5cab2b0402830A9772F21e022693F084443aBb9 | [BaseScan](https://basescan.org/tx/0x7fc6d49c1ba72d13410029949d9a3e44547127b1c977c7cdd38b2207f278003c) |
| 8453                | Base  | RewardsStore.sol | 0xeC997d583F42F394413f05DFef77f61BD2006cA1 | [BaseScan](https://basescan.org/tx/0x0b3f575ac934cab9d5bb6ff6b564ce00352f8bdd530fe66671e3a7456abfb31e) |
| 8453                | Base  | StakedBRR.sol | 0x9A2a2E71071Caff506050bE6747B4E1369964933 | [BaseScan](https://basescan.org/tx/0x0544d1484029a9debb28c32f74a038bf6a319eed64deb115d4955ca5b58e34e4) |
