    
// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.2 <0.9.0;

// 1、call会创建一个新的执行上下文(被调用方法的合约)，并把数据保存在新的上下文
// 2、delegatecall 会使用当前合约的执行上下文，并把数据保存在当前的上下文
// 3、为什么是使用delegatecall ————升级合约

contract A {

    uint private num;

    function setNum(uint _num) public {
        num = _num + 1;
    }

    function getNum() public view returns(uint) {
        return num;
    }

    function bSetNum(address _bAddress,uint _num) public {
        B b = B(_bAddress);
        b.setNum(_num);
    }

    function bSetNumCall(address _bAddress,uint _num) public {
        (bool res,) = _bAddress.call(abi.encodeWithSignature("setNum(uint256)",_num));
        if(!res) revert();
    }

    function bSetNumDelegateCall(address _bAddress,uint _num) public {
        (bool res,) = _bAddress.delegatecall(abi.encodeWithSignature("setNum(uint256)",_num));
        if(!res) revert();
    }
}

contract B {
    uint public num;
    uint public num2;
    
    //Call与DelegateCall谁来提交该事件?
    event NumEvent(uint indexed num);

    function setNum(uint _num) public {
         num = _num + 2;
         emit NumEvent(num);
    }
}

