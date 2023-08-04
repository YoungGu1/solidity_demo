// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;


// 1、在链端部署该智能合约
// 2、写一个前端页面调用链端的合约

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

// 0x407D6951E828e70f70fC5701b913BCE6ba133e40
contract MyToken is ERC20 {
    constructor() ERC20("MyToken", "MTK") {
        _mint(msg.sender, 10000 * 10 ** decimals());
    }
}

