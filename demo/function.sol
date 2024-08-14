// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9;

contract FunctionExample {
    //函数是智能合约的灵魂，没有函数智能合约就没有自己的行为
    //函数必须放在合约、接口和类库里面
    //接口里的函数是没有方法体，由实现该接口的智能合约去完成函数/方法功能

    //function <function name> (<parameter types>) {internal|external|public|private} [pure|view|payable] [returns (<return types>)]

    string private name = "Bob";
    uint256 private age = 100;

    function getName() public view returns (string memory) {
        return name;
    }

    function setName(string calldata _name) public {
        name = _name;
    }
    //为什么该函数没有立刻返回值
    function setName2(string calldata _name) public returns (string memory) {
        name = _name;
        return _name;
    }

    function getNameAndAge() public view returns (string memory, uint256) {
        return (name, age);
    }

}

