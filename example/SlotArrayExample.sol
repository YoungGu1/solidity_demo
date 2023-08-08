// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

//静态数组和动态数组的存储在插槽，它们之间存在差异

contract SlotArrayExample {
    
    /*
        uint默认是256位，32个字节，单独占用一个插槽
        uint8默认是8位，1个字节
    
    */

    //slot0 = 1;
    //slot1 = 2;
    //slot2 = 3;
    //slot3 = 4;
    //slot4 = 5;
    uint[5] private iArray = [1,2,3,4,5];
    //slot5 = Hello
    string private name = "Hello";
    //slot6 = 5 数组的长度
    uint[] private iArrayDynamic = [5,4,3,2,1];
    //slot7 = 3
    uint8[] private i8ArrayDynamic = [1,2,3];
    //slot8 = 2
    string[] private stringArrayDynamic = ["Hello","World"];
    //slot9 = 2;
    string[] private stringGreatThan32ArrayDynamic = ["HelloHelloHelloHelloHelloHello012345678","WorldWorldWorldWorldWorldWorld012345"];

    //获取小于或等于32个字节插槽的数据
    function getBytes32BySlot(uint256 slot) public view returns (bytes32) {
        bytes32 valueBytes32;
        assembly {
            valueBytes32 := sload(slot)
        }
        return valueBytes32;
    }

    //计算储存数据插槽 
    function calculateLocation(uint256 slot, uint256 index) public pure returns (uint256) {
        return uint256(keccak256(abi.encodePacked(slot))) + index ;
    }
    
     //Hash插槽 
    function keccak256Slot(uint256 slot) public pure returns (uint256) {
       // bytes32 paddedSlot = bytes32(slot);
        bytes32 baseSlot = keccak256(abi.encodePacked(slot));
        uint256 iBaseSlot = uint256(baseSlot);
        return iBaseSlot;
    }

}

