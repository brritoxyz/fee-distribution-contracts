// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

import "forge-std/Test.sol";
import {Authority} from "solmate/auth/Auth.sol";
import {FlywheelCore} from "flywheel-v2/FlywheelCore.sol";
import {IFlywheelRewards} from "flywheel-v2/interfaces/IFlywheelRewards.sol";
import {IFlywheelBooster} from "flywheel-v2/interfaces/IFlywheelBooster.sol";
import {FlywheelDynamicRewards} from "flywheel-v2/rewards/FlywheelDynamicRewards.sol";
import {StakedBRR} from "src/StakedBRR.sol";
import {DynamicRewards} from "src/DynamicRewards.sol";
import {RewardsStore} from "src/RewardsStore.sol";
import {ERC20} from "solmate/tokens/ERC20.sol";

contract Helper is Test {
    address public constant WETH = 0x4200000000000000000000000000000000000006;
    uint32 public constant REWARDS_CYCLE_LENGTH = 1 weeks;
    address public immutable owner = address(this);
    FlywheelCore public immutable flywheel;
    StakedBRR public immutable stakedBRR;
    DynamicRewards public immutable dynamicRewards;
    RewardsStore public immutable dynamicRewardsStore;

    constructor() {
        flywheel = new FlywheelCore(
            ERC20(WETH),
            IFlywheelRewards(address(0)),
            IFlywheelBooster(address(0)),
            owner,
            Authority(address(0))
        );
        stakedBRR = new StakedBRR(address(flywheel));
        dynamicRewards = new DynamicRewards(
            WETH,
            flywheel,
            REWARDS_CYCLE_LENGTH
        );
        dynamicRewardsStore = dynamicRewards.rewardsStore();

        flywheel.setFlywheelRewards(dynamicRewards);
        flywheel.addStrategyForRewards(ERC20(address(stakedBRR)));

        assertEq(address(dynamicRewards), address(flywheel.flywheelRewards()));
        assertEq(owner, flywheel.owner());

        (uint224 index, uint32 lastUpdatedTimestamp) = flywheel.strategyState(
            ERC20(address(stakedBRR))
        );

        assertEq(index, flywheel.ONE());
        assertEq(lastUpdatedTimestamp, block.timestamp);
        assertEq(address(flywheel), address(stakedBRR.flywheel()));
        assertEq(address(flywheel), address(dynamicRewards.flywheel()));
        assertEq(REWARDS_CYCLE_LENGTH, dynamicRewards.rewardsCycleLength());
        assertEq(WETH, dynamicRewardsStore.rewardToken());
        assertEq(
            address(dynamicRewards),
            dynamicRewardsStore.flywheelRewards()
        );

        deal(WETH, address(this), 100 ether);
    }
}
