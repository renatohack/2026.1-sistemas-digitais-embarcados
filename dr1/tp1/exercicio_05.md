# Exercício 5

## Função analisada

\[
F(A,B,C)=(A\lor B)\land (\lnot C)
\]

## Comportamento lógico

A saída `F` vale `1` somente quando:
- `C=0`; e
- pelo menos uma entre `A` ou `B` vale `1`.

Se `C=1`, a saída sempre é `0` por causa do fator `NOT C`.

## Tabela verdade

| A | B | C | F = (A OR B) AND (NOT C) |
|---|---|---|---|
| 0 | 0 | 0 | 0 |
| 0 | 0 | 1 | 0 |
| 0 | 1 | 0 | 1 |
| 0 | 1 | 1 | 0 |
| 1 | 0 | 0 | 1 |
| 1 | 0 | 1 | 0 |
| 1 | 1 | 0 | 1 |
| 1 | 1 | 1 | 0 |

## Coerência entre descrição e tabela

A tabela confirma a descrição textual: os únicos casos com `F=1` são `(A,B,C) = (0,1,0), (1,0,0), (1,1,0)`.
