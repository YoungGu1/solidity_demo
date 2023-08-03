// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;

// 1、ABI (Application binary interface)
// 2、了解ABI工作流程
// 3、通过代码了解ABI

contract ABIExample {

    string hello ="Hello Solidity";
    
    function getHello() public view returns (string memory) {
        return hello;
    }
    function setHello(string calldata _hello) public {
        hello = _hello;
    }
}

