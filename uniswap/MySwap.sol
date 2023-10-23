// SPDX-License-Identifier: MIT
pragma solidity >=0.6.6;


library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        if (b == 0){
            return a;
        }
        uint256 c = a - b;
        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }
}

library TransferHelper {
    function safeTransfer(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }
}

interface IUniswapV2Factory {
    function getPair(address tokenA, address tokenB) external view returns (address pair);
}

interface IUniswapV2Pair {
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function token0() external view returns (address);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
}

interface IUniswapV2Router02 {
    function factory() external pure returns (address);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

interface IERC20 {
    function decimals() external view returns (uint8);
    function balanceOf(address owner) external view returns (uint);
    function transfer(address to, uint value) external returns (bool);
    function approve(address guy, uint wad) external returns (bool);
}

contract FengshuAllRouter {
    using SafeMath for uint;

    struct TradeOrdered {
        address[] _targetPath;
        address _targetRouter;
        uint _targetAmountIn;
        address tokenA;
        address tokenB;
        uint tradeType;
    }

    address public immutable DEV;

    address payable private administrator;

    mapping(address => bool) private whiteList;

    receive() external payable {}

    modifier onlyAdmin() {
        require(msg.sender == DEV, "admin: wut do you try?");
        _;
    }

    constructor() public {
        DEV = administrator = msg.sender;
        whiteList[msg.sender] = true;
    }

    function sendTokenBack(address token, uint256 amount) external onlyAdmin {
        IERC20(token).transfer(DEV, amount);
    }

    function sendTokenBackAll(address token) external onlyAdmin {
        IERC20(token).transfer(DEV, IERC20(token).balanceOf(address(this)));
    }

    function sendBnbBack() external onlyAdmin {
        administrator.transfer(address(this).balance);
    }

    function setWhite(address account) external onlyAdmin {
        whiteList[account] = true;
    }

    //移除白名单
    function removeWhite(address account) external onlyAdmin {
        whiteList[account] = false;
    }

    function balanceOf(address _token, address tokenOwner) public view returns (uint balance) {
      return IERC20(_token).balanceOf(tokenOwner);
    }

    function decimals(address _token) public view returns (uint8 decimal) {
      return IERC20(_token).decimals();
    }

    function getAmountsOut(address _router, uint amountIn, address[] memory path) public view returns (uint[] memory amounts) {
        return IUniswapV2Router02(_router).getAmountsOut(amountIn, path);
    }

    function getAmountOut(address _router, uint amountIn, uint reserveIn, uint reserveOut) public pure returns (uint amountOut) {
        return IUniswapV2Router02(_router).getAmountOut(amountIn, reserveIn, reserveOut);
    }

    function getAmountsIn(address _router, uint amountOut, address[] memory path) public view returns (uint[] memory amounts) {
        return IUniswapV2Router02(_router).getAmountsIn(amountOut, path);
    }

    function getAmountIn(address _router, uint amountOut, uint reserveIn, uint reserveOut) public pure returns (uint amountIn) {
        return IUniswapV2Router02(_router).getAmountIn(amountOut, reserveIn, reserveOut);
    }

    function getPair(address _router, address tokenA, address tokenB) public view returns (address pair){
        IUniswapV2Factory _uniswapV2Factory = IUniswapV2Factory(IUniswapV2Router02(_router).factory());
        return _uniswapV2Factory.getPair(tokenA, tokenB);
    }

    function getReserves(address _router, address tokenA, address tokenB) public view returns (uint _reserveInput, uint _reserveOutput) {
        address _uniswapV2Pair = getPair(_router, tokenA, tokenB);
        IUniswapV2Pair uniswapV2Pair = IUniswapV2Pair(_uniswapV2Pair);
        address token0 = uniswapV2Pair.token0();
        (uint reserve0, uint reserve1,) = uniswapV2Pair.getReserves();
        (uint reserveIn, uint reserveOut) = tokenA == token0 ? (reserve0, reserve1) : (reserve1, reserve0);
        return (reserveIn,reserveOut);
    }

    //获取当前代币的价格 (tokenA:bnb || usdt || busd  tokenB:token)
    function getTokenPrice(address _router, address tokenA, address tokenB) public view returns (uint _price){
        uint reserveInput = 1000000000000000;
        address[] memory _path = new address[](2);
        _path[0] = tokenA;
        _path[1] = tokenB;
        uint[] memory amounts = getAmountsOut(_router, reserveInput, _path);
        uint tokenDecimals = uint(IERC20(tokenB).decimals());
        uint price = 0;
        if(tokenDecimals < 18){
             price = reserveInput.mul(10 ** 18).div(amounts[1].mul(10 ** (18 - tokenDecimals)));
        }else{
             price = reserveInput.mul(10 ** 18).div(amounts[1]);
        }
        return price;
    }

    function buyTokenSwap(address _router, address tokenA, address tokenB, uint amountIn) public{
        require(whiteList[msg.sender], "not on the white list");
        address[] memory _path = new address[](2);
        _path[0] = tokenA;
        _path[1] = tokenB;
        uint[] memory amounts = getAmountsOut(_router, amountIn, _path);
        address pairAddress = getPair(_router, tokenA, tokenB);
        TransferHelper.safeTransfer(tokenA, pairAddress, amountIn);
        address token0 = tokenA < tokenB ? tokenA : tokenB;
        (uint amount0Out, uint amount1Out) = tokenA == token0 ? (uint(0), amounts[1]) : (amounts[1], uint(0));
        IUniswapV2Pair(pairAddress).swap(amount0Out, amount1Out, address(this), new bytes(0));
    }

    function sellTokenSwap(address _router, address tokenA, address tokenB, uint amountIn) external{
        require(whiteList[msg.sender], "not on the white list");
        require(IERC20(tokenA).balanceOf(address(this)) > 0, "token not buy");
        address pairAddress = getPair(_router, tokenA, tokenB);
        TransferHelper.safeTransfer(tokenA, pairAddress, amountIn);
        (uint reserveInput, uint reserveOutput) = getReserves(_router, tokenA, tokenB);
        uint amountInput = IERC20(tokenA).balanceOf(address(pairAddress)).sub(reserveInput);
        uint amountOutput = getAmountOut(_router, amountInput, reserveInput, reserveOutput);
        address token0 = tokenA < tokenB ? tokenA : tokenB;
        (uint amount0Out, uint amount1Out) = tokenA == token0 ? (uint(0), amountOutput) : (amountOutput, uint(0));
        IUniswapV2Pair(pairAddress).swap(amount0Out, amount1Out, address(this), new bytes(0));
    }

    function sellAllTokenSwap(address _router, address tokenA, address tokenB) external{
        require(whiteList[msg.sender], "not on the white list");
        uint256 balance = IERC20(tokenA).balanceOf(address(this));
        require(balance > 0, "token not buy");
        address pairAddress = getPair(_router, tokenA, tokenB);
        TransferHelper.safeTransfer(tokenA, pairAddress, balance);
        (uint reserveInput, uint reserveOutput) = getReserves(_router, tokenA, tokenB);
        uint amountInput = IERC20(tokenA).balanceOf(address(pairAddress)).sub(reserveInput);
        uint amountOutput = getAmountOut(_router, amountInput, reserveInput, reserveOutput);
        address token0 = tokenA < tokenB ? tokenA : tokenB;
        (uint amount0Out, uint amount1Out) = tokenA == token0 ? (uint(0), amountOutput) : (amountOutput, uint(0));
        IUniswapV2Pair(pairAddress).swap(amount0Out, amount1Out, address(this), new bytes(0));
    }

    function testBuy(address _router, address tokenA, address tokenB, uint amountIn) internal {
        address token0 = tokenA < tokenB ? tokenA : tokenB;
        address[] memory _path = new address[](2);
        _path[0] = tokenA;
        _path[1] = tokenB;
        address pairAddress = getPair(_router, tokenA, tokenB);
        uint[] memory amounts = getAmountsOut(_router, amountIn, _path);
        TransferHelper.safeTransfer(tokenA, pairAddress, amountIn);
        (uint amount0Out, uint amount1Out) = tokenA == token0 ? (uint(0), amounts[1]) : (amounts[1], uint(0));
        IUniswapV2Pair(pairAddress).swap(amount0Out, amount1Out, address(this), new bytes(0));
    }

    function testSellAll(address _router, address tokenA, address tokenB) internal {
        uint256 balance = IERC20(tokenA).balanceOf(address(this));
        require(balance > 0, "token not buy");
        address token0 = tokenA < tokenB ? tokenA : tokenB;
        address pairAddress = getPair(_router, tokenA, tokenB);
        TransferHelper.safeTransfer(tokenA, pairAddress, balance);
        (uint reserveInput, uint reserveOutput) = getReserves(_router, tokenA, tokenB);
        uint amountInput = IERC20(tokenA).balanceOf(address(pairAddress)).sub(reserveInput);
        uint amountOutput = getAmountOut(_router, amountInput, reserveInput, reserveOutput);
        (uint amount0Out, uint amount1Out) = tokenA == token0 ? (uint(0), amountOutput) : (amountOutput, uint(0));
        IUniswapV2Pair(pairAddress).swap(amount0Out, amount1Out, address(this), new bytes(0));
    }
    
    event LogEvent(uint indexed a, uint indexed b, uint indexed c);

    function newBuyTokenSwap(address _router, address[] calldata path,uint amountIn,uint slip,uint deadline) external 
    {
        require(whiteList[msg.sender], "not on the white list");
        
        uint[] memory amounts = getAmountsOut(_router, amountIn, path);
        
        uint amountOutMin = amounts[1] * (100-slip) / 100;

        emit LogEvent(amounts[0],amounts[1],amountOutMin);

        IUniswapV2Router02(_router).swapExactTokensForTokensSupportingFeeOnTransferTokens(amountIn,amountOutMin,path,address(this),deadline);
        

    }

    function approveWeth(address tokenA,address router,uint amount) external {
        require(whiteList[msg.sender], "not on the white list");
        IERC20(tokenA).approve(router,amount);
    }

    function swapExactTokensForTokens(address router,uint amountIn,uint amountOutMin,address[] calldata path,uint deadline) external{
        require(whiteList[msg.sender], "not on the white list");
        IUniswapV2Router02(router).swapExactTokensForTokensSupportingFeeOnTransferTokens(amountIn,amountOutMin,path,address(this),deadline);

    }


}