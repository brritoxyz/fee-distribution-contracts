// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

import "forge-std/Test.sol";
import {SafeTransferLib} from "solady/utils/SafeTransferLib.sol";
import {RewardsStore} from "src/RewardsStore.sol";
import {Helper} from "test/Helper.sol";

contract RewardsStoreTest is Test, Helper {
    using SafeTransferLib for address;

    /*//////////////////////////////////////////////////////////////
                             transferNextCycleRewards
    //////////////////////////////////////////////////////////////*/

    function testCannotTransferNextCycleRewardsUnauthorized() external {
        address msgSender = address(this);

        assertTrue(msgSender != dynamicRewardsStore.flywheelRewards());

        vm.prank(msgSender);
        vm.expectRevert(RewardsStore.Unauthorized.selector);

        dynamicRewardsStore.transferNextCycleRewards();
    }

    function testTransferNextCycleRewards() external {
        address msgSender = dynamicRewardsStore.flywheelRewards();

        deal(WETH, address(dynamicRewardsStore), 1e18);

        uint256 rewardsStoreWETHBalance = WETH.balanceOf(
            address(dynamicRewardsStore)
        );
        uint256 flywheelRewardsWETHBalance = WETH.balanceOf(msgSender);

        vm.prank(msgSender);

        dynamicRewardsStore.transferNextCycleRewards();

        assertEq(0, WETH.balanceOf(address(dynamicRewardsStore)));
        assertEq(
            flywheelRewardsWETHBalance + rewardsStoreWETHBalance,
            WETH.balanceOf(msgSender)
        );
    }

    function testTransferNextCycleRewardsFuzz(uint256 amount) external {
        address msgSender = dynamicRewardsStore.flywheelRewards();

        deal(WETH, address(dynamicRewardsStore), amount);

        uint256 rewardsStoreWETHBalance = WETH.balanceOf(
            address(dynamicRewardsStore)
        );
        uint256 flywheelRewardsWETHBalance = WETH.balanceOf(msgSender);

        vm.prank(msgSender);

        dynamicRewardsStore.transferNextCycleRewards();

        assertEq(0, WETH.balanceOf(address(dynamicRewardsStore)));
        assertEq(
            flywheelRewardsWETHBalance + rewardsStoreWETHBalance,
            WETH.balanceOf(msgSender)
        );
    }
}
