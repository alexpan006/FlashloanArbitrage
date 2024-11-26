// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MockUniswapRouter {
    event SwapExecuted(address recipient, uint256 amountIn, uint256 amountOutMinimum);

    function exactInput(bytes calldata params) external returns (uint256) {
        emit SwapExecuted(msg.sender, 100, 110);
        return 110; // Mocked amount out
    }
}
