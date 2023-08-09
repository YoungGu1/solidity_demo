// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract MyWallet {

    using SafeERC20 for IERC20;
    address private erc20;
    address payable private owner;

    constructor(address _erc20){
        owner = payable(msg.sender);
        erc20 = _erc20;
    }

    //储存ERC20
    /*
        代理人是当前合约地址
        msg.sender发送amount数额币到当前合约地址address(this)
    */
    function depositERC20(uint256 amount) public {
        IERC20(erc20).safeTransferFrom(msg.sender, address(this), amount);
    }

    function withdrawERC20() external {
        require(msg.sender == owner,"Not owner");
        uint256 amount = getERC20Balance();
        IERC20(erc20).safeTransfer(msg.sender,amount);
    }

    //获取ERC20余额
    function getERC20Balance() public  view returns(uint256 amountERC20) {
        amountERC20 =  IERC20(erc20).balanceOf(address(this));
    }

    //储存ETH
    //amount参数是不必要的 调用payable方法就不用使用callBack或者receive
    function depositETH(uint256 amount) public payable {
        //不必要检验
        if(msg.value > 0){
            require(msg.value == amount);
        }
    }

    //获取ETH余额 
    function getETHBalance() public  view returns(uint256 amountETH) {
        amountETH = address(this).balance;
    }

    //修改ERC20地址 
    function setERC20(address _erc20) public {
         require(msg.sender == owner,"Not owner");
         erc20 = _erc20;
    }
    //获取ERC20地址
    function getERC20() public view returns (address) {
        return erc20;
    }



}