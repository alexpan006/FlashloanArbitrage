// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MockAavePoolAddressesProvider {
    event FlashLoanExecuted(address borrower, address asset, uint256 amount, bytes params);

    function flashLoanSimple(
        address receiverAddress,
        address asset,
        uint256 amount,
        bytes calldata params,
        uint16 referralCode
    ) external {
        emit FlashLoanExecuted(receiverAddress, asset, amount, params);
    }
}
