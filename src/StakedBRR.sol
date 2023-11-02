// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

import {ERC20} from "solady/tokens/ERC20.sol";
import {IFlywheelCore} from "src/interfaces/IFlywheelCore.sol";

contract StakedBRR is ERC20 {
    address private constant _BRR = 0x6d80d90ce251985bF41A98c6FDd6b7b975Fff884;
    string private constant _NAME = "Fee printer go brr";
    string private constant _SYMBOL = "stakedBRR";

    IFlywheelCore public immutable flywheel;

    constructor(address _flywheel) {
        flywheel = IFlywheelCore(_flywheel);
    }

    function name() public pure override returns (string memory) {
        return _NAME;
    }

    function symbol() public pure override returns (string memory) {
        return _SYMBOL;
    }

    /**
     * @notice Accrue user rewards upon stakedBRR deposit/mint, withdraw/burn, and transfers.
     * @param  from  address  Token sender.
     * @param  to    address  Token receiver.
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256
    ) internal override {
        // Save gas by not calling `accrue` for the zero address.
        if (from != address(0)) flywheel.accrue(this, from);
        if (to != address(0)) flywheel.accrue(this, to);
    }
}
