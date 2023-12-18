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

contract FeeDistributorScript is Script {
    address public constant WETH = 0x4200000000000000000000000000000000000006;
    uint32 public constant REWARDS_CYCLE_LENGTH = 1 weeks;

    function run() public {
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));

        FlywheelCore flywheel = new FlywheelCore(
            ERC20(WETH),
            IFlywheelRewards(address(0)),
            IFlywheelBooster(address(0)),
            vm.envAddress("OWNER"),
            Authority(address(0))
        );
        DynamicRewards dynamicRewards = new DynamicRewards(
            flywheel,
            REWARDS_CYCLE_LENGTH,
            vm.envAddress("OWNER")
        );
        RewardsStore dynamicRewardsStore = new RewardsStore(
            WETH,
            address(dynamicRewards)
        );
        ERC20 stakedBRR = ERC20(address(new StakedBRR(address(flywheel))));

        dynamicRewards.setRewardsStore(address(dynamicRewardsStore));
        flywheel.setFlywheelRewards(dynamicRewards);
        flywheel.addStrategyForRewards(ERC20(address(stakedBRR)));

        vm.stopBroadcast();
    }
}
