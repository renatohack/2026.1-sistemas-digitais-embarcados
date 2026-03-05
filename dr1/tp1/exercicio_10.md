# Exercício 10

## Função

\[
F(A,B,C)=(A\land B)\lor(\lnot C)
\]

## Por que a função é descrita integralmente por álgebra booleana e tabela verdade

A expressão booleana define formalmente a relação lógica entre entradas e saída.
A tabela verdade enumera todas as combinações possíveis (`2^3 = 8`) e o valor de `F` em cada caso.

Como a lógica digital é binária e finita por combinação de entradas, expressão + tabela verdade fornecem uma especificação completa e sem ambiguidades do comportamento da função.

## Importância antes da implementação em hardware

Essa representação prévia é essencial para:
- validar o comportamento esperado antes de sintetizar ou montar circuito;
- evitar erros conceituais que geram retrabalho em FPGA, microcontrolador ou ASIC;
- facilitar revisão técnica, documentação e testes de verificação.

Em resumo, primeiro se valida a lógica; depois se escolhe a tecnologia de implementação.

