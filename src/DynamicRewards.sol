// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import {ERC20} from "solmate/tokens/ERC20.sol";
import {FlywheelCore} from "flywheel-v2/FlywheelCore.sol";
import {FlywheelDynamicRewards} from "flywheel-v2/rewards/FlywheelDynamicRewards.sol";
import {Ownable} from "solady/auth/Ownable.sol";
import {SafeCastLib} from "solady/utils/SafeCastLib.sol";
import {RewardsStore} from "src/RewardsStore.sol";

contract DynamicRewards is Ownable, FlywheelDynamicRewards {
    using SafeCastLib for uint256;

    RewardsStore public rewardsStore;

    event SetRewardsStore(address);

    error InvalidAddress();

    constructor(
        FlywheelCore _flywheel,
        uint32 _rewardsCycleLength,
        address initialOwner
    ) FlywheelDynamicRewards(_flywheel, _rewardsCycleLength) {
        _initializeOwner(initialOwner);
    }

    /**
     * Set the rewards store.
     * @param _rewardsStore  address  RewardsStore contract address.
     */
    function setRewardsStore(address _rewardsStore) external onlyOwner {
        if (_rewardsStore == address(0)) revert InvalidAddress();

        rewardsStore = RewardsStore(_rewardsStore);

        emit SetRewardsStore(_rewardsStore);
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

    /*//////////////////////////////////////////////////////////////
                    ENFORCE 2-STEP OWNERSHIP TRANSFERS
    //////////////////////////////////////////////////////////////*/

    function transferOwnership(address) public payable override {}

    function renounceOwnership() public payable override {}
}
