 

// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

//1、Keccak-256是一种哈希算法函数，被广泛应用于以太坊中。对于任何输入数据，经过哈希计算后都会得到固定长度为32字节的哈希值。
//2、对于Keccak-256哈希算法函数，无法通过其生成的哈希值推算出原始输入数据。
//3、Keccak-256来自SHA-3算法的优化。
//4、SHA-256也是一种哈希算法函数，用于比特币中。相比之下，Keccak-256算法的效率更高。
//5、keccak256函数只接收字节作为参数，通常使用abi将数据转换成字节bytes,再进行hash
//6、abi.encode与abi.encodePacked都可以将任意类型数据转换成字节，但他们是有区别的.

contract KeccakExample {

    function hashStringWithEncode(string memory _str) public pure returns(bytes32) {
        return keccak256(abi.encode(_str));
    }
    
    function hashStringWithEncodePacked(string memory _str) public pure returns(bytes32) {
        return keccak256(abi.encodePacked(_str));
    }

    function encodeString(string memory _str) public pure returns(bytes memory) {
        return abi.encode(_str);
    }

    function encodePackedString(string memory _str) public pure returns(bytes memory) {
        return abi.encodePacked(_str);
    }

    //0xfa26db7ca85ead399216e7c6316bc50ed24393c3122b582735e7f3b0f91b93f0
    //0xfa26db7ca85ead399216e7c6316bc50ed24393c3122b582735e7f3b0f91b93f0
    //hello world == hellow orld == 0xfa26db7ca85ead399216e7c6316bc50ed24393c3122b582735e7f3b0f91b93f0
    function hashWithParams(string memory _str1, string memory _str2) public pure returns(bytes32) {
        return keccak256(abi.encodePacked(_str1,_str2));
    }

    function hashWithParams2(string memory _str1, string memory _str2, uint256 _age) public pure returns(bytes32) {
        return keccak256(abi.encodePacked(_str1,_str2,_age));
    }

}
