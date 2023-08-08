// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

/**
    abi.encode   转换成16进制32位，会保存文本的信息，所以占用字节比较长
    abi.encodePacked  直接转换转换成16进制  
    keccak256    把字节转换成32位字节的hash值 唯一
    
**/
contract KeccakExample  {

    //转换成字节  
    function encodeStringy(string memory _str) public pure returns (bytes memory){
        return abi.encode(_str);
    }

    function encodePackedString(string memory _str) public pure returns(bytes memory){
        return abi.encodePacked(_str);
    }

    function hashString(string memory _str) public pure returns (bytes32){
        return keccak256(abi.encode(_str));
    }

    function hashPackedString(string memory _str) public pure returns (bytes32){
        return keccak256(abi.encodePacked(_str));
    }

    function hashWithParams(string memory _a,string memory _b) public pure returns (bytes32){
        return keccak256(abi.encodePacked(_a,_b));
    }


}
