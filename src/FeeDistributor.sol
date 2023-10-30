// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

import {FlywheelCore} from "flywheel-v2/FlywheelCore.sol";
import {IFlywheelRewards} from "flywheel-v2/interfaces/IFlywheelRewards.sol";
import {IFlywheelBooster} from "flywheel-v2/interfaces/IFlywheelBooster.sol";
import {FlywheelCore} from "flywheel-v2/FlywheelCore.sol";
import {ERC20} from "solmate/tokens/ERC20.sol";
import {Authority} from "solmate/auth/Auth.sol";

contract FeeDistributor is FlywheelCore {
    ERC20 private constant _WETH =
        ERC20(0x4200000000000000000000000000000000000006);

    constructor(
        address _owner
    )
        FlywheelCore(
            _WETH,
            IFlywheelRewards(address(0)),
            IFlywheelBooster(address(0)),
            _owner,
            Authority(address(0))
        )
    {}
}
