# Exercício 7

## Funções

\[
F1(A,B)=A\land B
\]
\[
F2(A,B,C)=(A\land B)\lor C
\]

## Tabela verdade de F1

| A | B | F1 = A AND B |
|---|---|---|
| 0 | 0 | 0 |
| 0 | 1 | 0 |
| 1 | 0 | 0 |
| 1 | 1 | 1 |

## Tabela verdade de F2

| A | B | C | F2 = (A AND B) OR C |
|---|---|---|---|
| 0 | 0 | 0 | 0 |
| 0 | 0 | 1 | 1 |
| 0 | 1 | 0 | 0 |
| 0 | 1 | 1 | 1 |
| 1 | 0 | 0 | 0 |
| 1 | 0 | 1 | 1 |
| 1 | 1 | 0 | 1 |
| 1 | 1 | 1 | 1 |

## Entradas de LUT necessárias

- `F1`: LUT de **2 entradas** (`2^2 = 4` posições).
- `F2`: LUT de **3 entradas** (`2^3 = 8` posições).

## Impacto do aumento do número de variáveis

Quando o número de variáveis aumenta, o número de combinações cresce exponencialmente (`2^n`).
Isso aumenta:
- o tamanho da tabela verdade;
- a quantidade de informação armazenada em LUT;
- a complexidade de análise e validação lógica.

