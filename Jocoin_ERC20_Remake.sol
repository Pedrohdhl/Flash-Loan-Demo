// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

//É mais fácil importar os métodos básicos de ERC20
//É uma versão mais compacta do jocoin.sol feito em aulas passadas
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract JoCoin is ERC20 {

    //Não usaremos todos os métodos, apenas Transfer
    constructor() ERC20("jocoin", "JoC") {

        _mint(msg.sender, 1000000); //A wallet recebe todos os Jocoins
    }

}
