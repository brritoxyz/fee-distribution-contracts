// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

import "forge-std/Test.sol";
import {Authority} from "solmate/auth/Auth.sol";
import {FeeDistributor} from "src/FeeDistributor.sol";
import {StakedBRR} from "src/StakedBRR.sol";
import {ERC20} from "solmate/tokens/ERC20.sol";

contract FeeDistributorTest is Test {
    FeeDistributor public immutable distributor;
    StakedBRR public immutable stakedBRR;

    constructor() {
        distributor = new FeeDistributor(address(this), Authority(address(0)));
        stakedBRR = new StakedBRR(address(distributor));
    }
}
