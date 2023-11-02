// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

import "forge-std/Test.sol";
import {ERC20} from "solmate/tokens/ERC20.sol";
import {SafeTransferLib} from "solady/utils/SafeTransferLib.sol";
import {RewardsStore} from "src/RewardsStore.sol";
import {Helper} from "test/Helper.sol";

contract DynamicRewardsTest is Test, Helper {
    using SafeTransferLib for address;

    /*//////////////////////////////////////////////////////////////
                             getNextCycleRewards
    //////////////////////////////////////////////////////////////*/

    function testGetNextCycleRewards() external {
        uint256 amount = 1e18;

        deal(WETH, address(dynamicRewardsStore), amount);

        assertEq(
            address(dynamicRewards),
            dynamicRewardsStore.flywheelRewards()
        );

        ERC20 strategy = ERC20(address(stakedBRR));
        (, uint32 lastUpdatedTimestamp) = flywheel.strategyState(strategy);
        uint256 dynamicRewardsWETHBalance = WETH.balanceOf(
            address(dynamicRewards)
        );

        // The `getAccruedRewards` is only callable by the FlywheelCore contract.
        // We're calling `getAccruedRewards` since it's publicly accessible,
        // meanwhile, `getNextCycleRewards` is internal.
        vm.prank(address(flywheel));

        uint256 accruedAmount = dynamicRewards.getAccruedRewards(
            strategy,
            lastUpdatedTimestamp
        );

        // Zero since it's the beginning of a new reward dist. cycle.
        assertEq(0, accruedAmount);

        assertEq(
            dynamicRewardsWETHBalance + amount,
            WETH.balanceOf(address(dynamicRewards))
        );
    }

    function testGetNextCycleRewardsFuzz(uint192 amount) external {
        deal(WETH, address(dynamicRewardsStore), amount);

        assertEq(
            address(dynamicRewards),
            dynamicRewardsStore.flywheelRewards()
        );

        ERC20 strategy = ERC20(address(stakedBRR));
        (, uint32 lastUpdatedTimestamp) = flywheel.strategyState(strategy);
        uint256 dynamicRewardsWETHBalance = WETH.balanceOf(
            address(dynamicRewards)
        );

        vm.prank(address(flywheel));

        uint256 accruedAmount = dynamicRewards.getAccruedRewards(
            strategy,
            lastUpdatedTimestamp
        );

        assertEq(0, accruedAmount);
        assertEq(
            dynamicRewardsWETHBalance + uint256(amount),
            WETH.balanceOf(address(dynamicRewards))
        );
    }
}
