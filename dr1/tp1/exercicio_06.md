# Exercício 6

## Função

\[
F(A,B,C)=(A\lor B)\land C
\]

## Tabela verdade

| A | B | C | F = (A OR B) AND C |
|---|---|---|---|
| 0 | 0 | 0 | 0 |
| 0 | 0 | 1 | 0 |
| 0 | 1 | 0 | 0 |
| 0 | 1 | 1 | 1 |
| 1 | 0 | 0 | 0 |
| 1 | 0 | 1 | 1 |
| 1 | 1 | 0 | 0 |
| 1 | 1 | 1 | 1 |

## Interpretação como conteúdo de LUT

Uma LUT implementa função booleana mapeando combinações de entrada para bits de saída.
Para `A,B,C`, existem `2^3 = 8` combinações, então a LUT armazena 8 bits.

Se o endereço da LUT seguir a ordem binária `ABC = 000` até `111`, o conteúdo é:

\[
[0,0,0,1,0,1,0,1]
\]

Esse vetor é exatamente a tabela verdade da função.

## Número de entradas da LUT

São necessárias **3 entradas** (LUT de 3 variáveis).

