// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import {ERC20} from "solmate/tokens/ERC20.sol";
import {IFlywheelCore} from "src/interfaces/IFlywheelCore.sol";

contract MockFlywheelCore is IFlywheelCore {
    struct AccrueCall {
        ERC20 strategy;
        address user;
    }

    AccrueCall public accrueCall;
    uint256 public counter;

    function accrue(ERC20 strategy, address user) external returns (uint256) {
        accrueCall = AccrueCall(strategy, user);

        return ++counter;
    }
}
