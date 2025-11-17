// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./interfaces.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

//precisamos que os contratos possam conversar entre si
interface IHelper {
    function performArbitrage(uint256 loanAmount) external;
}

contract FlashLoanReceiver is IFlashLoanReceiver{

    IFlashLoanLender private immutable lender;
    IERC20 private immutable token;

    // Adicionamos uma variável para armazenar o endereço do contrato Helper.
    address private immutable arbitrageHelper;

    //Passamos o endereço do lender e do token
    //Precisamos fazer uma transferência do token para pagar as fee's da transação
    //Precisamos do endereço do helper para transação lucrativa
    constructor(
        address _lenderAddress,
        address _tokenAddress,
        address _helperAddress
    ) {
        lender = IFlashLoanLender(_lenderAddress);
        token = IERC20(_tokenAddress);
        arbitrageHelper = _helperAddress;
    }

    function onFlashLoan(
        uint256 amount,
        uint256 fee
    ) external override {

        //1. Checa se o endereço do lender é o mesmo repassado no construtor
        require(
            msg.sender == address(lender),
            "ERRO: Endereco do lender incorreto"
        );
        
        // Antes de pagar o empréstimo, executamos a arbitragem.
        //O objetivo do flash loan é o lucro.

        // 2. Envia o dinheiro do empréstimo para o Helper
        token.transfer(arbitrageHelper, amount);

        // 3. Chama o Helper para gerar o "lucro"
        // O Helper irá nos enviar de volta (amount + 1% de lucro)
        IHelper(arbitrageHelper).performArbitrage(amount);

        // ---------------------------------------------
        
        // 4. Paga o valor do empréstimo + taxa
        // (Agora temos o lucro da arbitragem para pagar a taxa!)
        // IMPORTANTE: A taxa é paga no retorno do capital, se o receiver pede 100000, ele receberá 100000 e não 99910 (capital - taxa de 0.09%)
        // Caso ele não possa pagar, a transação é revertida.
        uint256 amountToRepay = amount + fee;
        token.transfer(address(lender), amountToRepay);
    }

    function executeFlashLoan(uint256 amount) external {
        lender.flashLoan(
            address(this),  
            amount          
        );
    }

    //serve apenas para checar o balance da conta
    function Balance() external view returns (uint256) {
        return token.balanceOf(address(this));
    }
}
