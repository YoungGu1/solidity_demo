// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

contract KeccakExample  {

    function encodeString(string memory _str) public pure returns (bytes memory){
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
