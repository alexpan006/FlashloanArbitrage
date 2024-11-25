// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";
import {FlashLoanSimpleReceiverBase} from "@aave/core-v3/contracts/flashloan/base/FlashLoanSimpleReceiverBase.sol";
import {IPoolAddressesProvider} from "@aave/core-v3/contracts/interfaces/IPoolAddressesProvider.sol";
import {IERC20} from "@aave/core-v3/contracts/dependencies/openzeppelin/contracts/IERC20.sol";

contract FlashLoanArbitrageFinalV5_0901 is FlashLoanSimpleReceiverBase {
    ISwapRouter public uniswapRouter;
    address payable owner;
    uint256 private amountOutMinimum;

    constructor(address _aavePoolAddress, address _uniswapRouterAddress)
        FlashLoanSimpleReceiverBase(IPoolAddressesProvider(_aavePoolAddress))
    {
        uniswapRouter = ISwapRouter(_uniswapRouterAddress);
        owner = payable(msg.sender);

    }

    function executeArbitrage (
        address asset,
        uint256 amount,
        uint256 amountout,
        bytes calldata params
    ) external onlyOwner {
        // Request a flash loan from Aave
        amountOutMinimum = amountout;
        POOL.flashLoanSimple(address(this), asset, amount, params, 0);
    }

    function executeOperation(
        address asset,
        uint256 amount,
        uint256 premium,
        address initiator,
        bytes calldata params
    ) external override returns (bool){


        // Approve Uniswap to spend the asset
        IERC20(asset).approve(address(uniswapRouter), amount);
      


        // Set up the parameters for the swap
        ISwapRouter.ExactInputParams memory swapParams = ISwapRouter.ExactInputParams({
            path: params,
            recipient: address(this),
            deadline: block.timestamp+120,
            amountIn: amount,
            amountOutMinimum: amountOutMinimum // You should calculate an appropriate minimum amount out
        });

        // Execute the swap on Uniswap V3
        uniswapRouter.exactInput(swapParams);

        // Repay the flash loan
        uint256 totalDebt = amount + premium;
        IERC20(asset).approve(address(POOL), totalDebt);

        return true;
    }

    function getBalance(address _tokenAddress) external view returns (uint256) {
        return IERC20(_tokenAddress).balanceOf(address(this));
    }

    function withdraw(address _tokenAddress) external onlyOwner {
        IERC20 token = IERC20(_tokenAddress);
        token.transfer(msg.sender, token.balanceOf(address(this)));
    }

    modifier onlyOwner() {
        require(
            msg.sender == owner,
            "Only the contract owner can call this function"
        );
        _;
    }



}
