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
    ERC20 private constant _WETH =
        ERC20(0x4200000000000000000000000000000000000006);

    address public immutable owner = address(this);
    FeeDistributor public immutable distributor;
    StakedBRR public immutable stakedBRR;
    DynamicRewards public immutable dynamicRewards;

    constructor() {
        distributor = new FeeDistributor(owner, Authority(address(0)));
        stakedBRR = new StakedBRR(address(distributor));
        dynamicRewards = new DynamicRewards(address(_WETH), distributor);

        distributor.setFlywheelRewards(dynamicRewards);
    }
}
