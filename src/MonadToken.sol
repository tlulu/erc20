// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {ERC20} from "./ERC20.sol";

contract MonadToken is ERC20 {
    constructor() ERC20("MonadToken", "MON") {}

    function mint(uint256 amount) public {
        _mint(msg.sender, amount);
    }

    function mint(address sender, uint256 amount) public {
        _mint(sender, amount);
    }
}