// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

import {FlywheelCore} from "flywheel-v2/FlywheelCore.sol";
import {FlywheelDynamicRewards} from "flywheel-v2/rewards/FlywheelDynamicRewards.sol";
import {ERC20} from "solmate/tokens/ERC20.sol";
import {SafeCastLib} from "solady/utils/SafeCastLib.sol";
import {RewardsStore} from "src/RewardsStore.sol";

contract DynamicRewards is FlywheelDynamicRewards {
    using SafeCastLib for uint256;

    uint32 private constant _REWARDS_CYCLE_LENGTH = 1 weeks;
    RewardsStore public immutable rewardsStore;

    constructor(
        address _rewardToken,
        FlywheelCore _flywheel
    ) FlywheelDynamicRewards(_flywheel, _REWARDS_CYCLE_LENGTH) {
        rewardsStore = new RewardsStore(_rewardToken, address(this));
    }

    /**
     * @notice Retrieves next cycle's rewards from the store contract to ensure proper accounting.
     */
    function getNextCycleRewards(ERC20) internal override returns (uint192) {
        return rewardsStore.transferNextCycleRewards().toUint192();
    }
}