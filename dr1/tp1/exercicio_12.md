# Exercício 12

## Função revisada

\[
F(A,B,C)=(A\lor B)\land(\lnot C)
\]

## Expressão booleana final validada

\[
F=(A+B)\cdot\overline{C}
\]

## Tabela verdade final

| A | B | C | F |
|---|---|---|---|
| 0 | 0 | 0 | 0 |
| 0 | 0 | 1 | 0 |
| 0 | 1 | 0 | 1 |
| 0 | 1 | 1 | 0 |
| 1 | 0 | 0 | 1 |
| 1 | 0 | 1 | 0 |
| 1 | 1 | 0 | 1 |
| 1 | 1 | 1 | 0 |

## Confirmação de equivalência

A expressão e a tabela representam exatamente o mesmo comportamento:
- `F=1` somente quando `C=0` e ao menos uma entre `A` ou `B` é `1`;
- nos demais casos, `F=0`.

Versão final revisada e validada registrada neste arquivo.
