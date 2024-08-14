 
 
// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;
import "hardhat/console.sol";

// 为什么要进行encode和decode，以及它们的使用

// Encode and Decode
contract EncodeDecode {

    struct Employee {
        string name;
        uint[2] nums;
    }
    
    //编码
    function encode(uint age,address addr, uint[] calldata arr, Employee calldata employee) external pure returns (bytes memory)
    {
        return abi.encode(age, addr, arr, employee);
    }
    //解码
    function decode(bytes calldata data) external pure returns ( uint age, address addr, uint[] memory arr, Employee memory employee) 
    {
        (age, addr, arr, employee) = abi.decode(data, (uint, address, uint[], Employee));
        console.log(employee.name);
    }

    string public name;
    uint256 public score;

    function setNameAge(string memory _name, uint256 _score) public {
        name = _name;
        score = _score;
    }
    //0x16eda3f9000000000000000000000000000000000000000000000000000000000000004000000000000000000000000000000000000000000000000000000000000000c80000000000000000000000000000000000000000000000000000000000000004416c657800000000000000000000000000000000000000000000000000000000
    function getSetNameAgeBytes4() public pure returns (bytes4) {
        return bytes4(keccak256("setNameAge(string,uint256)"));
    }

    function getParamsBytes(string memory _name, uint256 _score) public pure returns (bytes memory)
    {
        return abi.encode(_name, _score);
    }

    fallback() external {}
    
}

