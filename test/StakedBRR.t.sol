// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "forge-std/Test.sol";
import {ERC20} from "solady/tokens/ERC20.sol";
import {ERC20 as SolmateERC20} from "solmate/tokens/ERC20.sol";
import {SafeTransferLib} from "solady/utils/SafeTransferLib.sol";
import {StakedBRR} from "src/StakedBRR.sol";
import {Helper} from "test/Helper.sol";

contract StakedBRRTest is Test, Helper {
    using SafeTransferLib for address;

    address public constant BRR = 0x6d80d90ce251985bF41A98c6FDd6b7b975Fff884;
    string private constant NAME = "Fee printer go brr";
    string private constant SYMBOL = "stakedBRR";

    constructor() {
        deal(BRR, address(this), 100e18);
        deal(WETH, address(dynamicRewardsStore), 100e18);
    }

    /*//////////////////////////////////////////////////////////////
                             name
    //////////////////////////////////////////////////////////////*/

    function testName() external {
        assertEq(NAME, stakedBRR.name());
    }

    /*//////////////////////////////////////////////////////////////
                             symbol
    //////////////////////////////////////////////////////////////*/

    function testSymbol() external {
        assertEq(SYMBOL, stakedBRR.symbol());
    }

    /*//////////////////////////////////////////////////////////////
                             stake
    //////////////////////////////////////////////////////////////*/

    function testCannotStakeInvalidTo() external {
        address to = address(0);
        uint256 amount = 1;

        vm.expectRevert(StakedBRR.InvalidTo.selector);

        stakedBRR.stake(to, amount);
    }

    function testCannotStakeTransferFromFailedInsufficientAllowance() external {
        address to = address(this);
        uint256 amount = BRR.balanceOf(address(this));

        assertEq(0, ERC20(BRR).allowance(address(this), address(stakedBRR)));

        vm.expectRevert(SafeTransferLib.TransferFromFailed.selector);

        stakedBRR.stake(to, amount);
    }

    function testCannotStakeTransferFromFailedInsufficientBalance() external {
        address to = address(this);
        uint256 amount = BRR.balanceOf(address(this)) + 1;

        BRR.safeApprove(address(stakedBRR), type(uint256).max);

        assertEq(
            type(uint256).max,
            ERC20(BRR).allowance(address(this), address(stakedBRR))
        );

        vm.expectRevert(SafeTransferLib.TransferFromFailed.selector);

        stakedBRR.stake(to, amount);
    }

    function testStake() external {
        address to = address(this);
        uint256 amount = BRR.balanceOf(address(this));
        uint256 brrBalanceBefore = BRR.balanceOf(address(this));
        uint256 stakedBRRBalanceBefore = stakedBRR.balanceOf(address(this));
        uint256 wethRewards = WETH.balanceOf(address(dynamicRewardsStore));

        BRR.safeApprove(address(stakedBRR), type(uint256).max);

        vm.expectEmit(true, true, true, true, BRR);

        emit ERC20.Transfer(address(this), address(stakedBRR), amount);

        vm.expectEmit(true, true, true, true, address(stakedBRR));

        emit ERC20.Transfer(address(0), to, amount);

        stakedBRR.stake(to, amount);

        assertEq(brrBalanceBefore - amount, BRR.balanceOf(address(this)));
        assertEq(stakedBRRBalanceBefore + amount, stakedBRR.balanceOf(to));

        // Sanity check - make sure that the rewards accrue and are distributed correctly.
        // For simplicity's sake, the test contract will own 100% of the supply and rewards.
        assertEq(stakedBRR.totalSupply(), stakedBRR.balanceOf(to));

        // Should be zero since no time has elapsed since staking.
        assertEq(0, flywheel.rewardsAccrued(to));

        // Fast forward the entire rewards cycle length to claim 100% of the rewards.
        vm.warp(block.timestamp + dynamicRewards.rewardsCycleLength());

        flywheel.accrue(SolmateERC20(address(stakedBRR)), to);

        assertEq(wethRewards, flywheel.rewardsAccrued(to));

        uint256 wethBalanceBefore = WETH.balanceOf(to);

        flywheel.claimRewards(to);

        assertEq(wethBalanceBefore + amount, WETH.balanceOf(to));
        assertEq(0, flywheel.rewardsAccrued(to));
    }

    function testStakeFuzz(address to, uint88 amount) external {
        vm.assume(to != address(0) && amount != 0);

        deal(BRR, address(this), amount);

        uint256 brrBalanceBefore = BRR.balanceOf(address(this));
        uint256 stakedBRRBalanceBefore = stakedBRR.balanceOf(to);
        uint256 wethRewards = WETH.balanceOf(address(dynamicRewardsStore));

        BRR.safeApprove(address(stakedBRR), type(uint256).max);

        vm.expectEmit(true, true, true, true, BRR);

        emit ERC20.Transfer(address(this), address(stakedBRR), amount);

        vm.expectEmit(true, true, true, true, address(stakedBRR));

        emit ERC20.Transfer(address(0), to, amount);

        stakedBRR.stake(to, amount);

        assertEq(brrBalanceBefore - amount, BRR.balanceOf(address(this)));
        assertEq(stakedBRRBalanceBefore + amount, stakedBRR.balanceOf(to));
        assertEq(stakedBRR.totalSupply(), stakedBRR.balanceOf(to));
        assertEq(0, flywheel.rewardsAccrued(to));

        // Due to rounding, there may be a small amount of rewards that aren't issued (less than 0.01%).
        uint256 wethRewardsWithErrorMargin = (wethRewards * 9_999) / 10_000;

        vm.warp(block.timestamp + dynamicRewards.rewardsCycleLength());

        flywheel.accrue(SolmateERC20(address(stakedBRR)), to);

        assertLe(wethRewardsWithErrorMargin, flywheel.rewardsAccrued(to));

        uint256 wethBalanceBefore = WETH.balanceOf(to);

        flywheel.claimRewards(to);

        assertLe(
            wethBalanceBefore + wethRewardsWithErrorMargin,
            WETH.balanceOf(to)
        );
        assertEq(0, flywheel.rewardsAccrued(to));
    }

    /*//////////////////////////////////////////////////////////////
                             unstake
    //////////////////////////////////////////////////////////////*/

    function testCannotUnstakeInvalidTo() external {
        address to = address(0);
        uint256 amount = 1;

        vm.expectRevert(StakedBRR.InvalidTo.selector);

        stakedBRR.unstake(to, amount);
    }

    function testCannotUnstakeInsufficientBalance() external {
        address to = address(this);
        uint256 amount = 1;

        vm.expectRevert(ERC20.InsufficientBalance.selector);

        stakedBRR.unstake(to, amount);
    }

    function testUnstake() external {
        address to = address(this);
        uint256 amount = BRR.balanceOf(address(this));

        BRR.safeApprove(address(stakedBRR), type(uint256).max);

        stakedBRR.stake(to, amount);

        uint256 stakedBRRBalance = stakedBRR.balanceOf(address(this));
        uint256 brrBalance = BRR.balanceOf(to);

        vm.expectEmit(true, true, true, true, address(stakedBRR));

        emit ERC20.Transfer(address(this), address(0), amount);

        vm.expectEmit(true, true, true, true, BRR);

        emit ERC20.Transfer(address(stakedBRR), to, amount);

        stakedBRR.unstake(to, amount);

        assertEq(stakedBRRBalance - amount, stakedBRR.balanceOf(address(this)));
        assertEq(brrBalance + amount, BRR.balanceOf(to));
    }

    function testUnstakeFuzz(address to, uint88 amount) external {
        vm.assume(to != address(0) && amount != 0);

        deal(BRR, address(this), amount);

        BRR.safeApprove(address(stakedBRR), type(uint256).max);

        stakedBRR.stake(address(this), amount);

        uint256 stakedBRRBalance = stakedBRR.balanceOf(address(this));
        uint256 brrBalance = BRR.balanceOf(to);

        vm.expectEmit(true, true, true, true, address(stakedBRR));

        emit ERC20.Transfer(address(this), address(0), amount);

        vm.expectEmit(true, true, true, true, BRR);

        emit ERC20.Transfer(address(stakedBRR), to, amount);

        stakedBRR.unstake(to, amount);

        assertEq(stakedBRRBalance - amount, stakedBRR.balanceOf(address(this)));
        assertEq(brrBalance + amount, BRR.balanceOf(to));
    }
}
