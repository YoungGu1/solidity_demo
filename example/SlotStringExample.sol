// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract SlotStringExample {
    
    //0x48656c6c6f48656c6c6f48656c6c6f48656c6c6f48656c6c6f48656c6c6f003c
    //0x48656c6c6f48656c6c6f48656c6c6f48656c6c6f48656c6c6f48656c6c6f303e
    //0x0000000000000000000000000000000000000000000000000000000000000043
    /*
        如果大于32位，那么直接取插槽位得到的就是字符串长度
        calculateBaseSlot计算后,就得到前面32位所在插槽的数据
        calculateBaseSlot计算后+1,就得到后面几位所在插槽的数据
    */
    string private hello = "HelloHelloHelloHelloHelloHello01201231231312"; //0x00 slot
    
    //获取小于或等于32个字节插槽的数据
    function getBytes32BySlot(uint256 slot) public view returns (bytes32) {
        bytes32 valueBytes32;
        assembly {
            valueBytes32 := sload(slot)
        }
        return valueBytes32;
    }

    //获取大于32个字节的第一个插槽数据
    //0x48656c6c6f48656c6c6f48656c6c6f48656c6c6f48656c6c6f48656c6c6f3031
    function getFirstSlot(uint256 slot) public view returns (bytes32) {
        uint256 firstDataSlot = calculateBaseSlot(slot);
        bytes32 valueBytes32;
        assembly {
            valueBytes32 := sload(firstDataSlot)
        }
        return valueBytes32;
    }

    //获取大于32个字节的第二个插槽数据
    //0x3200000000000000000000000000000000000000000000000000000000000000
    function getSecondSlot(uint256 slot) public view returns (bytes32) {
        uint256 firstDataSlot = calculateBaseSlot(slot);
        ++firstDataSlot;
        bytes32 valueBytes32;
        assembly {
            valueBytes32 := sload(firstDataSlot)
        }
        return valueBytes32;
    }

     //计算插槽 
    function calculateBaseSlot(uint256 slot) public pure returns (uint256) {
        //0x0000000000000000000000000000000000000000000000000000000000000000;
        bytes32 paddedSlot = bytes32(slot);
        bytes32 baseSlot = keccak256(abi.encodePacked(paddedSlot));
        uint256 iBaseSlot = uint256(baseSlot);
        return iBaseSlot;
    }

}

