// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

import {ERC4626} from "solady/tokens/ERC4626.sol";

contract StakedBRR is ERC4626 {
    address private constant _BRR = 0x6d80d90ce251985bF41A98c6FDd6b7b975Fff884;
    string private constant _NAME = "Fee printer go brr";
    string private constant _SYMBOL = "stakedBRR";

    function asset() public pure override returns (address) {
        return _BRR;
    }

    function name() public pure override returns (string memory) {
        return _NAME;
    }

    function symbol() public pure override returns (string memory) {
        return _SYMBOL;
    }
}
