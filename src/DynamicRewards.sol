// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

import {FlywheelCore} from "flywheel-v2/FlywheelCore.sol";
import {FlywheelDynamicRewards} from "flywheel-v2/rewards/FlywheelDynamicRewards.sol";
import {ERC20} from "solmate/tokens/ERC20.sol";
import {SafeCastLib} from "solady/utils/SafeCastLib.sol";
import {RewardsStore} from "src/RewardsStore.sol";

contract DynamicRewards is FlywheelDynamicRewards {
    using SafeCastLib for uint256;

    RewardsStore public immutable rewardsStore;

    constructor(
        address _rewardToken,
        FlywheelCore _flywheel,
        uint32 _rewardsCycleLength
    ) FlywheelDynamicRewards(_flywheel, _rewardsCycleLength) {
        rewardsStore = new RewardsStore(_rewardToken, address(this));
    }

    /**
     * @notice Retrieves next cycle's rewards from the store contract to ensure proper accounting.
     * @dev    For the sake of simplicity, we're not making use of the `strategy` param (assumption
     *         is that stakedBRR is the only strategy - if this changes later, can update FlywheelRewards).
     *         FlywheelCore also adds a layer of protection by checking whether the strategy exists
     *         before calling `FlywheelDynamicRewards.getAccruedRewards`.
     */
    function getNextCycleRewards(ERC20) internal override returns (uint192) {
        return rewardsStore.transferNextCycleRewards().toUint192();
    }
}
