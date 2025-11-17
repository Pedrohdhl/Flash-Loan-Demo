// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

//A função do ArbitrageHelper é simular uma transação lucrativa com o receiver
//justificando um flash loan nesse contexto
//O lucro é de 1% sobre o valor enviado
contract ArbitrageHelper {
    
    // O endereço do token Jocoin
    IERC20 public immutable token;

    constructor(address _tokenAddress) {
        token = IERC20(_tokenAddress);
    }

    function performArbitrage(uint256 loanAmount) external {
        
        // Garante que o Receiver enviou os fundos ANTES de chamar esta função.
        uint256 balance = token.balanceOf(address(this));
        require(balance >= loanAmount, "ERRO: Fundos nao recebidos");
        
        // Ele calcula um lucro (1%) e envia o valor original + lucro
        
        uint256 profit = loanAmount / 100; // Lucro de 1%
        uint256 amountToReturn = loanAmount + profit;

        // Garante que temos fundos suficientes em nosso pool para pagar o lucro
        require(balance >= amountToReturn, "ERRO: Pool de lucro insuficiente");

        // Envia o empréstimo + lucro de volta para quem chamou (o Receiver)
        token.transfer(msg.sender, amountToReturn);
    }
}
