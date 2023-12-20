// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "forge-std/Test.sol";
import {Helper} from "test/Helper.sol";

contract StakedBRRTest is Test, Helper {
    address public constant BRR = 0x6d80d90ce251985bF41A98c6FDd6b7b975Fff884;
    string private constant NAME = "Fee printer go brr";
    string private constant SYMBOL = "stakedBRR";

    constructor() {
        deal(BRR, address(this), 100e18);
        deal(WETH, address(this), 100e18);
    }

    /*//////////////////////////////////////////////////////////////
                             name
    //////////////////////////////////////////////////////////////*/

    function testName() external {
        assertEq(NAME, stakedBRR.name());
    }

    /*//////////////////////////////////////////////////////////////
                             symbol
    //////////////////////////////////////////////////////////////*/

    function testSymbol() external {
        assertEq(SYMBOL, stakedBRR.symbol());
    }

    /*//////////////////////////////////////////////////////////////
                             stake
    //////////////////////////////////////////////////////////////*/
}
