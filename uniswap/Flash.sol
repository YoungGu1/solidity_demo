// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
// bsc mainnet 0x8C5Ae9aA1bB83677dCBA9236fCa9f69010297885
interface functionContract {

    swapExactTokensForTokens(
    uint amountIn,
    uint amountOutMin,
    address[] calldata path,
    address to,
    uint deadline
    ) external returns (uint[] memory amounts);

    token0() external view returns (address);

    token1() external view returns (address);

    name() external pure returns (string memory);

    transfer(address to, uint value) external returns (bool);

    balanceOf(address owner) external view returns (uint);

    allowance(address owner, address spender) external view returns (uint);

    approve(address spender, uint value) external returns (bool);

    swap(uint amount0Out, uint amount1Out, address to, bytes calldata) external;

    getPair(address tokenA, address tokenB) external view returns (address pair);

    getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);

    getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
}


contract FlashSwap {

    address public owner;
    mapping(address => uint) public sign;

    modifier onlySign(address checkaddress){
        (sign[checkaddress] == 1, 'ns');
        _;
    }

    constructor(address signaddress, address _owner) {
        sign[signaddress] = 1;
        owner = _owner;
    }

    updateOwner(address _owner) public onlySign(msg.sender) {
        owner = _owner;
    }

    addSign(address signaddress) public onlySign(msg.sender) {
        sign[signaddress] = 1;
    }

    tokenTransferAll(address tokenaddress, address receiveaddress) public onlySign(msg.sender) {
        functionContract token = functionContract(tokenaddress);
        uint token_balance = token.balanceOf(address(this));
        token.transfer(receiveaddress, token_balance);
    }

    flashSwap(
    uint _maxBlockNumber,
    uint _amountToken, // 借多少个 token 币
    address _tokenBack, // 归还的币种
    address _tokenLoan, // 借出币种
    address _sourceRouter,
    address _targetRouter,
    address _pairAddress
    ) external onlySign(msg.sender) {
        (block.number <= _maxBlockNumber, '00');

        int profit = check(_amountToken, _tokenBack, _tokenLoan, _sourceRouter, _targetRouter);
        (profit > 0, '01');

        address token0 = functionContract(_pairAddress).token0();
        address token1 = functionContract(_pairAddress).token1();


        functionContract(_pairAddress).swap(
        _tokenLoan == token0 ? _amountToken : 0,
        _tokenLoan == token1 ? _amountToken : 0,
        address(this),
        abi.encode(_sourceRouter, _targetRouter)
        );
    }

    check(
    uint _amountToken, // 借出的币种
    address _tokenBack,
    address _tokenLoan,
    address _sourceRouter,
    address _targetRouter
    ) internal view returns (int) {
        address[] memory path1 = new address[](2);
        address[] memory path2 = new address[](2);

        path1[0] = path2[1] = _tokenBack;
        path1[1] = path2[0] = _tokenLoan;
        // 算出归还数量
        uint amountBack = functionContract(_sourceRouter).getAmountsIn(_amountToken, path1)[0];
        // 交换所得数量
        uint amountRepay = functionContract(_targetRouter).getAmountsOut(_amountToken, path2)[1];
        // 这里如果最后得出来是负数会 fail
        return int(amountRepay - amountBack);
    }

    execute(
    address _sender,
    uint _amount0,
    uint _amount1,
    bytes calldata _
    ) internal {
        uint amountToken = _amount0 == 0 ? _amount1 : _amount0;
        functionContract pair = functionContract(msg.sender);
        // 这个得验证
        address token0 = pair.token0();
        address token1 = pair.token1();

        address[] memory path1 = new address[](2);
        address[] memory path2 = new address[](2);

        address forward;
        address backward;
        (_amount0 == 0) {
            forward = token0;
            backward = token1;
        }  {
            forward = token1;
            backward = token0;
        }

        path1[0] = path2[1] = forward;
        path1[1] = path2[0] = backward;

        (address sourceRouter, address targetRouter) = abi.decode(_, (address, address));
        functionContract token = functionContract(backward);
        (token.allowance(address(this), targetRouter) == 0) {
            token.approve(targetRouter, type(uint256).max);
        }

        uint amountRequired = functionContract(sourceRouter).getAmountsIn(amountToken, path1)[0];
        uint amountReceived = functionContract(targetRouter).swapExactTokensForTokens(
        amountToken,
        amountRequired,
        path2,
        address(this),
        block.timestamp + 60
        )[1];

        functionContract otherToken = functionContract(forward);
        otherToken.transfer(msg.sender, amountRequired);
        //不进行转移了，等币足够多的时候再转移，先放在合约中，节省 gas
        // otherToken.transfer(owner, amountReceived - amountRequired);
    }

    pancakeCall(address _sender, uint256 _amount0, uint256 _amount1, bytes calldata _) external {
        execute(_sender, _amount0, _amount1, _);
    }

    BiswapCall(address _sender, uint256 _amount0, uint256 _amount1, bytes calldata _) external {
        execute(_sender, _amount0, _amount1, _);
    }

    babyCall(address sender, uint amount0, uint amount1, bytes calldata) external {
        execute(sender, amount0, amount1,);
    }

    apeCall(address sender, uint amount0, uint amount1, bytes calldata) external {
        execute(sender, amount0, amount1,);
    }

    // julswap
    BSCswapCall(address sender, uint amount0, uint amount1, bytes calldata) external {
        execute(sender, amount0, amount1,);
    }

    fstswapCall(address sender, uint256 amount0, uint256 amount1, bytes calldata) external {
        execute(sender, amount0, amount1,);
    }

    // mdex
    swapV2Call(address _sender, uint256 _amount0, uint256 _amount1, bytes calldata _) external {
        execute(_sender, _amount0, _amount1, _);
    }

}