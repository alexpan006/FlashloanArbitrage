// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@aave/core-v3/contracts/interfaces/IPool.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";

contract FlashLoanArbitrageFinalV3 {
    IPool public aavePool;
    ISwapRouter public uniswapRouter;
    address payable owner;

    constructor(address _aavePoolAddress, address _uniswapRouterAddress) {
        aavePool = IPool(_aavePoolAddress);
        uniswapRouter = ISwapRouter(_uniswapRouterAddress);
        owner = payable(msg.sender);

    }

    function executeArbitrage (
        address asset,
        uint256 amount,
        bytes calldata params
    ) external {
        // Request a flash loan from Aave
        aavePool.flashLoanSimple(address(this), asset, amount, params, 0);
    }

    function executeOperation(
        address asset,
        uint256 amount,
        uint256 premium,
        address initiator,
        bytes calldata params
    ) external returns (bool) {
        // Ensure the call is from the Aave pool
        require(msg.sender == address(aavePool), "Caller must be Aave pool");


        // Approve Uniswap to spend the asset
        IERC20(asset).approve(address(uniswapRouter), amount);


        // Set up the parameters for the swap
        ISwapRouter.ExactInputParams memory swapParams = ISwapRouter.ExactInputParams({
            path: params,
            recipient: address(this),
            deadline: block.timestamp+120,
            amountIn: amount,
            amountOutMinimum: 0 // You should calculate an appropriate minimum amount out
        });

        // Execute the swap on Uniswap V3
        uniswapRouter.exactInput(swapParams);

        // Repay the flash loan
        uint256 totalDebt = amount + premium;
        IERC20(asset).transfer(address(aavePool), totalDebt);

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
