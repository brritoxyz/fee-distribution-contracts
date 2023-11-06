// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import {ERC20} from "solmate/tokens/ERC20.sol";

interface IFlywheelCore {
    function accrue(ERC20 strategy, address user) external returns (uint256);
}
