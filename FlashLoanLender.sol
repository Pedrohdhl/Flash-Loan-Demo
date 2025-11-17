// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./interfaces.sol";

contract FlashLoanLender is IFlashLoanLender {
    
    IERC20 public immutable token;
    //A fee base é 0.09%, para simular a AAVE
    uint256 private constant FEE_BASIS_POINTS = 9;
    uint256 private constant BASIS_POINTS_DENOMINATOR = 10000;

//O endereço do token é o endereço do contrato que fez o deploy de jocoin
    constructor(address _tokenAddress) {
        token = IERC20(_tokenAddress);
    }

    function flashLoan(
        address receiver,
        uint256 amount
    ) external override {
        
        // 1. Verifica se a quantidade disponível no Lender é maior que a quantidade requisitada
        uint256 balanceBefore = token.balanceOf(address(this));
        require(balanceBefore >= amount, "ERRO: A quantia excede o valor total");

        // 2. Calcula a taxa da operação (0.09%)
        uint256 fee = (amount * FEE_BASIS_POINTS) / BASIS_POINTS_DENOMINATOR;
        require(fee > 0, "ERRO: Quantia baixa demais para emprestimo");
        

        // 3. Empréstimo

        token.transfer(receiver, amount);

        IFlashLoanReceiver(receiver).onFlashLoan(
            amount,
            fee
        );

        // Verifica se o empréstimo foi pago
        uint256 balanceAfter = token.balanceOf(address(this));
        require(
            balanceAfter >= balanceBefore + fee,
            "ERRO: Flash loan nao foi pago!"
        );
    }

    function Balance() public view returns (uint256) {
        return token.balanceOf(address(this));
    }
}
