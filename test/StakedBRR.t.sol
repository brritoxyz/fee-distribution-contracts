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

        BRR.safeApprove(address(stakedBRR), type(uint256).max);

        vm.expectEmit(true, true, true, true, address(BRR));

        emit ERC20.Transfer(address(this), address(stakedBRR), amount);

        vm.expectEmit(true, true, true, true, address(stakedBRR));

        emit ERC20.Transfer(address(0), address(this), amount);

        stakedBRR.stake(to, amount);

        assertEq(brrBalanceBefore - amount, BRR.balanceOf(address(this)));
        assertEq(
            stakedBRRBalanceBefore + amount,
            stakedBRR.balanceOf(address(this))
        );

        // Sanity check - make sure that the rewards accrue and are distributed correctly.
        // For simplicity's sake, the test contract will own 100% of the supply and rewards.
        assertEq(stakedBRR.totalSupply(), stakedBRR.balanceOf(address(this)));

        // Should be zero since no time has elapsed since staking.
        assertEq(0, flywheel.rewardsAccrued(address(this)));

        // Fast forward the entire rewards cycle length to claim 100% of the rewards.
        vm.warp(block.timestamp + dynamicRewards.rewardsCycleLength());

        flywheel.accrue(SolmateERC20(address(stakedBRR)), address(this));

        assertEq(amount, flywheel.rewardsAccrued(address(this)));

        uint256 wethBalanceBefore = WETH.balanceOf(address(this));

        flywheel.claimRewards(address(this));

        assertEq(wethBalanceBefore + amount, WETH.balanceOf(address(this)));
    }
}
