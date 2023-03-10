// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { IPaymaster, ExecutionResult, PAYMASTER_VALIDATION_SUCCESS_MAGIC } from '@matterlabs/zksync-contracts/l2/system-contracts/interfaces/IPaymaster.sol';
import { IPaymasterFlow } from '@matterlabs/zksync-contracts/l2/system-contracts/interfaces/IPaymasterFlow.sol';
import { TransactionHelper, Transaction } from '@matterlabs/zksync-contracts/l2/system-contracts/libraries/TransactionHelper.sol';

import '@matterlabs/zksync-contracts/l2/system-contracts/Constants.sol';

contract MyPaymaster is IPaymaster {
    modifier onlyBootloader() {
        require(
            msg.sender == BOOTLOADER_FORMAL_ADDRESS,
            'Only bootloader can call this method'
        );
        // Continure execution if called from the bootloader.
        _;
    }

    function validateAndPayForPaymasterTransaction(
        bytes32,
        bytes32,
        Transaction calldata _transaction
    ) external payable returns (bytes4 magic, bytes memory context) {
        // By default we consider the transaction as accepted.
        magic = PAYMASTER_VALIDATION_SUCCESS_MAGIC;
        require(
            _transaction.paymasterInput.length >= 4,
            'The standard paymaster input must be at least 4 bytes long'
        );

        bytes4 paymasterInputSelector = bytes4(
            _transaction.paymasterInput[0:4]
        );
        if (paymasterInputSelector == IPaymasterFlow.approvalBased.selector) {
            // While the transaction data consists of address, uint256 and bytes data,
            // the data is not needed for this paymaster
            (address token, uint256 amount, bytes memory data) = abi.decode(
                _transaction.paymasterInput[4:],
                (address, uint256, bytes)
            );

            // Note, that while the minimal amount of ETH needed is tx.gasPrice * tx.gasLimit,
            // neither paymaster nor account are allowed to access this context variable.
            uint256 requiredETH = _transaction.gasLimit *
                _transaction.maxFeePerGas;

            // The bootloader never returns any data, so it can safely be ignored here.
            (bool success, ) = payable(BOOTLOADER_FORMAL_ADDRESS).call{
                value: requiredETH
            }('');
            require(success, 'Failed to transfer funds to the bootloader');
        } else {
            revert('Unsupported paymaster flow');
        }
    }

    function postTransaction(
        bytes calldata _context,
        Transaction calldata _transaction,
        bytes32,
        bytes32,
        ExecutionResult _txResult,
        uint256 _maxRefundedGas
    ) external payable override {
        // Refunds are not supported yet.
    }

    receive() external payable {}
}
