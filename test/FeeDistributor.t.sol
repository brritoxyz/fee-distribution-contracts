// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

import "forge-std/Test.sol";
import {Authority} from "solmate/auth/Auth.sol";
import {FlywheelDynamicRewards} from "flywheel-v2/rewards/FlywheelDynamicRewards.sol";
import {FeeDistributor} from "src/FeeDistributor.sol";
import {StakedBRR} from "src/StakedBRR.sol";
import {DynamicRewards} from "src/DynamicRewards.sol";
import {ERC20} from "solmate/tokens/ERC20.sol";

contract FeeDistributorTest is Test {
    address public constant WETH = 0x4200000000000000000000000000000000000006;
    uint32 public constant REWARDS_CYCLE_LENGTH = 1 weeks;
    address public immutable owner = address(this);
    FeeDistributor public immutable distributor;
    StakedBRR public immutable stakedBRR;
    DynamicRewards public immutable dynamicRewards;

    constructor(address _rewardToken) {
        distributor = new FeeDistributor(WETH, owner, Authority(address(0)));
        stakedBRR = new StakedBRR(address(distributor));
        dynamicRewards = new DynamicRewards(
            _rewardToken,
            distributor,
            REWARDS_CYCLE_LENGTH
        );

        distributor.setFlywheelRewards(dynamicRewards);
    }
}
