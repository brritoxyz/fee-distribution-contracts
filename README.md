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
| 8453                | Base  | DynamicRewards.sol | 0x103f7cf49e838966829c164435d4c76d06c6353c | [BaseScan](https://basescan.org/tx/0xca7c99beb5402e92bbc323f5802fae0dbbee4c8f3a57a673a83c596c22cf18d1) |
| 8453                | Base  | RewardsStore.sol | 0x6a693e727580f2bd4b96084d852ef9f036115cbb | [BaseScan](https://basescan.org/tx/0xc093ee4eb32ad6c20a67d705ffe14a99be84ce97379b0c1d0b7d4758d2a13f91) |
| 8453                | Base  | StakedBRR.sol | 0x9A2a2E71071Caff506050bE6747B4E1369964933 | [BaseScan](https://basescan.org/tx/0x0544d1484029a9debb28c32f74a038bf6a319eed64deb115d4955ca5b58e34e4) |
