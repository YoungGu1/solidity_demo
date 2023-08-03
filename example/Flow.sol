// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

//overflow 由正反向溢出称为上溢，它返回最小值
//underflow 由负方向溢出称为下溢，它返回最大值
//0.8.0以后版本，不需要开发人员处理溢出问题，而是交给虚拟机处理

/*
library SafeMath {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked{
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b > a) return (false, 0);
        return (true, a - b);
    }
   
}
*/

contract Flow {
    
    using SafeMath for uint;

    //overflowF 上溢
    //uint8 max 255
    function overflowF(uint8 eight)  public pure returns(uint8) {
        eight = eight + 1;
        return eight;
    }  

    //underflow 下溢
    function underflowF(uint8 eight)  public pure returns(uint8) {
        eight = eight - 10;
        return eight;
    } 

    //underflow2 下溢
    function underflowF2(int8 eight)  public pure returns(int8) {
        eight = eight - 100;
        return eight;
    } 

    //uint max 115792089237316195423570985008687907853269984665640564039457584007913129639935 
    function addF(uint a ,uint b) public pure returns (bool,uint) {
        return a.tryAdd(b);
    } 

    function addF2(uint a ,uint b) public pure returns (uint) {
        return a.add(b);
    } 

    function subF(uint a ,uint b) public pure returns (bool, uint) {
        return a.trySub(b);
    }


}