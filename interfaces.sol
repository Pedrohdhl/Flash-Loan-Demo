// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

//A função dessa interface é permitir que o lender e o receiver acessem os métodos um do outro.
interface IFlashLoanLender {
    function flashLoan(address receiver, uint256 amount) external;
}


interface IFlashLoanReceiver {
    function onFlashLoan(uint256 amount, uint256 fee) external;
}
