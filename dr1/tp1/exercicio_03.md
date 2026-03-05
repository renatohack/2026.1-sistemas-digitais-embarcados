# Exercício 3

## Função

\[
F(A,B,C)=(A \land B)\lor C
\]

## Tabela verdade

| A | B | C | F = (A AND B) OR C |
|---|---|---|---|
| 0 | 0 | 0 | 0 |
| 0 | 0 | 1 | 1 |
| 0 | 1 | 0 | 0 |
| 0 | 1 | 1 | 1 |
| 1 | 0 | 0 | 0 |
| 1 | 0 | 1 | 1 |
| 1 | 1 | 0 | 1 |
| 1 | 1 | 1 | 1 |

## Expressão booleana equivalente

\[
F = (A \cdot B) + C
\]

## Verificação de consistência

A tabela verdade é consistente com a expressão:
- se `C=1`, então `F=1` independentemente de `A` e `B`;
- se `C=0`, então `F` depende de `A·B`, sendo `1` apenas quando `A=1` e `B=1`.
