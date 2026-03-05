# Exercício 8

## Expressão booleana

\[
F(A,B,C)=A\lor (B\land C)
\]

## Tabela verdade

| A | B | C | F = A OR (B AND C) |
|---|---|---|---|
| 0 | 0 | 0 | 0 |
| 0 | 0 | 1 | 0 |
| 0 | 1 | 0 | 0 |
| 0 | 1 | 1 | 1 |
| 1 | 0 | 0 | 1 |
| 1 | 0 | 1 | 1 |
| 1 | 1 | 0 | 1 |
| 1 | 1 | 1 | 1 |

## Comportamento lógico (descrição técnica)

A saída `F` é `1` quando:
- `A=1` (independente de `B` e `C`), ou
- `B=1` e `C=1` simultaneamente.

Logo, com `A=0`, a função se reduz a `B AND C`.

