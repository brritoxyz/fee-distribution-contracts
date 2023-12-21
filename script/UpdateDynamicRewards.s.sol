// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "forge-std/Script.sol";
import {Authority} from "solmate/auth/Auth.sol";
import {ERC20} from "solmate/tokens/ERC20.sol";
import {FlywheelCore} from "flywheel-v2/FlywheelCore.sol";
import {IFlywheelRewards} from "flywheel-v2/interfaces/IFlywheelRewards.sol";
import {IFlywheelBooster} from "flywheel-v2/interfaces/IFlywheelBooster.sol";
import {FlywheelDynamicRewards} from "flywheel-v2/rewards/FlywheelDynamicRewards.sol";
import {DynamicRewards} from "src/DynamicRewards.sol";
import {RewardsStore} from "src/RewardsStore.sol";
import {StakedBRR} from "src/StakedBRR.sol";

contract UpdateDynamicRewardsScript is Script {
    address public constant WETH = 0x4200000000000000000000000000000000000006;
    uint32 public constant REWARDS_CYCLE_LENGTH = 1 weeks;
    FlywheelCore public constant FLYWHEEL =
        FlywheelCore(0x771F3Ec0BFCDdf107E9fD90e1B45e9d6001C65A5);

    function run() public {
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));

        DynamicRewards dynamicRewards = new DynamicRewards(
            FLYWHEEL,
            REWARDS_CYCLE_LENGTH,
            vm.envAddress("OWNER")
        );
        RewardsStore dynamicRewardsStore = new RewardsStore(
            WETH,
            address(dynamicRewards)
        );

        dynamicRewards.setRewardsStore(address(dynamicRewardsStore));

        vm.stopBroadcast();
    }
}
