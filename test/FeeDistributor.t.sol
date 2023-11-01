// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

import "forge-std/Test.sol";
import {Authority} from "solmate/auth/Auth.sol";
import {FlywheelDynamicRewards} from "flywheel-v2/rewards/FlywheelDynamicRewards.sol";
import {FeeDistributor} from "src/FeeDistributor.sol";
import {StakedBRR} from "src/StakedBRR.sol";
import {DynamicRewards} from "src/DynamicRewards.sol";
import {RewardsStore} from "src/RewardsStore.sol";
import {ERC20} from "solmate/tokens/ERC20.sol";

contract FeeDistributorTest is Test {
    address public constant WETH = 0x4200000000000000000000000000000000000006;
    uint32 public constant REWARDS_CYCLE_LENGTH = 1 weeks;
    address public immutable owner = address(this);
    FeeDistributor public immutable distributor;
    StakedBRR public immutable stakedBRR;
    DynamicRewards public immutable dynamicRewards;
    RewardsStore public immutable dynamicRewardsStore;

    constructor() {
        distributor = new FeeDistributor(WETH, owner, Authority(address(0)));
        stakedBRR = new StakedBRR(address(distributor));
        dynamicRewards = new DynamicRewards(
            WETH,
            distributor,
            REWARDS_CYCLE_LENGTH
        );
        dynamicRewardsStore = dynamicRewards.rewardsStore();

        distributor.setFlywheelRewards(dynamicRewards);
        distributor.addStrategyForRewards(ERC20(address(stakedBRR)));

        assertEq(
            address(dynamicRewards),
            address(distributor.flywheelRewards())
        );
        assertEq(owner, distributor.owner());

        (uint224 index, uint32 lastUpdatedTimestamp) = distributor
            .strategyState(ERC20(address(stakedBRR)));

        assertEq(index, distributor.ONE());
        assertEq(lastUpdatedTimestamp, block.timestamp);
        assertEq(address(distributor), address(stakedBRR.flywheel()));
        assertEq(address(distributor), address(dynamicRewards.flywheel()));
        assertEq(REWARDS_CYCLE_LENGTH, dynamicRewards.rewardsCycleLength());
        assertEq(WETH, dynamicRewardsStore.rewardToken());
        assertEq(
            address(dynamicRewards),
            dynamicRewardsStore.flywheelRewards()
        );

        deal(WETH, address(this), 100 ether);
    }

    function testTest() external {}
}
