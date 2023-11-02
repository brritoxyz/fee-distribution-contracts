// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

import "forge-std/Test.sol";
import {ERC20} from "solady/tokens/ERC20.sol";
import {SafeTransferLib} from "solady/utils/SafeTransferLib.sol";
import {StakedBRR} from "src/StakedBRR.sol";
import {MockFlywheelCore} from "test/mocks/MockFlywheelCore.sol";

contract StakedBRRTest is Test {
    using SafeTransferLib for address;

    address public constant BRR = 0x6d80d90ce251985bF41A98c6FDd6b7b975Fff884;
    MockFlywheelCore public immutable flywheel = new MockFlywheelCore();
    StakedBRR public immutable stakedBRR;

    event Transfer(address indexed from, address indexed to, uint256 amount);

    constructor() {
        stakedBRR = new StakedBRR(address(flywheel));
    }

    /*//////////////////////////////////////////////////////////////
                             stake
    //////////////////////////////////////////////////////////////*/

    function testCannotStakeInvalidTo() external {
        vm.expectRevert(StakedBRR.InvalidTo.selector);

        stakedBRR.stake(address(0), 1);
    }

    function testStake() external {
        address msgSender = address(this);
        address to = address(1);
        uint256 amount = 1;

        deal(BRR, msgSender, amount);

        uint256 msgSenderBRRBalance = BRR.balanceOf(msgSender);
        uint256 toStakedBRRBalance = stakedBRR.balanceOf(to);
        uint256 flywheelCounter = flywheel.counter();

        BRR.safeApprove(address(stakedBRR), amount);

        vm.expectEmit(true, true, false, true, BRR);

        emit Transfer(msgSender, address(stakedBRR), amount);

        vm.expectEmit(true, true, false, true, address(stakedBRR));

        emit Transfer(address(0), to, amount);

        stakedBRR.stake(to, amount);

        assertEq(msgSenderBRRBalance - amount, BRR.balanceOf(msgSender));
        assertEq(toStakedBRRBalance + amount, stakedBRR.balanceOf(to));
        assertEq(flywheelCounter + 1, flywheel.counter());

        (ERC20 strategy, address user) = flywheel.accrueCall();

        assertEq(address(stakedBRR), address(strategy));
        assertEq(to, user);
    }

    function testStakeFuzz(
        address msgSender,
        address to,
        uint256 amount
    ) external {
        vm.assume(to != address(0));

        deal(BRR, msgSender, amount);

        uint256 msgSenderBRRBalance = BRR.balanceOf(msgSender);
        uint256 toStakedBRRBalance = stakedBRR.balanceOf(to);
        uint256 flywheelCounter = flywheel.counter();

        vm.startPrank(msgSender);

        BRR.safeApprove(address(stakedBRR), amount);

        vm.expectEmit(true, true, false, true, BRR);

        emit Transfer(msgSender, address(stakedBRR), amount);

        vm.expectEmit(true, true, false, true, address(stakedBRR));

        emit Transfer(address(0), to, amount);

        stakedBRR.stake(to, amount);

        vm.stopPrank();

        assertEq(msgSenderBRRBalance - amount, BRR.balanceOf(msgSender));
        assertEq(toStakedBRRBalance + amount, stakedBRR.balanceOf(to));
        assertEq(flywheelCounter + 1, flywheel.counter());

        (ERC20 strategy, address user) = flywheel.accrueCall();

        assertEq(address(stakedBRR), address(strategy));
        assertEq(to, user);
    }

    /*//////////////////////////////////////////////////////////////
                             unstake
    //////////////////////////////////////////////////////////////*/

    function testCannotUnstakeInvalidTo() external {
        vm.expectRevert(StakedBRR.InvalidTo.selector);

        stakedBRR.unstake(address(0), 1);
    }

    function testUnstake() external {
        address msgSender = address(this);
        uint256 amount = 1;

        deal(BRR, msgSender, amount);
        BRR.safeApprove(address(stakedBRR), amount);
        stakedBRR.stake(msgSender, amount);

        address to = address(1);
        uint256 msgSenderStakedBRRBalance = stakedBRR.balanceOf(msgSender);
        uint256 toBRRBalance = BRR.balanceOf(to);
        uint256 flywheelCounter = flywheel.counter();

        vm.expectEmit(true, true, false, true, address(stakedBRR));

        emit Transfer(msgSender, address(0), amount);

        vm.expectEmit(true, true, false, true, BRR);

        emit Transfer(address(stakedBRR), to, amount);

        stakedBRR.unstake(to, amount);

        assertEq(
            msgSenderStakedBRRBalance - amount,
            stakedBRR.balanceOf(msgSender)
        );
        assertEq(toBRRBalance + amount, BRR.balanceOf(to));
        assertEq(flywheelCounter + 1, flywheel.counter());

        (ERC20 strategy, address user) = flywheel.accrueCall();

        assertEq(address(stakedBRR), address(strategy));
        assertEq(msgSender, user);
    }

    function testUnstakeFuzz(
        address msgSender,
        address to,
        uint256 amount
    ) external {
        vm.assume(msgSender != address(0) && to != address(0));

        deal(BRR, msgSender, amount);

        vm.startPrank(msgSender);

        BRR.safeApprove(address(stakedBRR), amount);
        stakedBRR.stake(msgSender, amount);

        vm.stopPrank();

        uint256 msgSenderStakedBRRBalance = stakedBRR.balanceOf(msgSender);
        uint256 toBRRBalance = BRR.balanceOf(to);
        uint256 flywheelCounter = flywheel.counter();

        vm.prank(msgSender);
        vm.expectEmit(true, true, false, true, address(stakedBRR));

        emit Transfer(msgSender, address(0), amount);

        vm.expectEmit(true, true, false, true, BRR);

        emit Transfer(address(stakedBRR), to, amount);

        stakedBRR.unstake(to, amount);

        assertEq(
            msgSenderStakedBRRBalance - amount,
            stakedBRR.balanceOf(msgSender)
        );
        assertEq(toBRRBalance + amount, BRR.balanceOf(to));
        assertEq(flywheelCounter + 1, flywheel.counter());

        (ERC20 strategy, address user) = flywheel.accrueCall();

        assertEq(address(stakedBRR), address(strategy));
        assertEq(msgSender, user);
    }
}
