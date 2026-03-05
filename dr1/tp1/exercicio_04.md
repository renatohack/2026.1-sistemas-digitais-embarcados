# Exercicio 4

## Expressoes dadas

\[
E1 = A \land B
\]
\[
E2 = \lnot C
\]

## Funcao construida (em termos de A, B e C)

\[
F(A,B,C) = (A \land B) \lor (\lnot C)
\]

## Relacao com E1 e E2

\[
F(A,B,C)=E1\lor E2
\]

## Expressao booleana final completa

\[
F=(A\cdot B)+\overline{C}
\]

## Condicoes para F = 1

A saida `F` e `1` quando ocorre pelo menos uma das condicoes:
- `C=0` (pois `NOT C = 1`);
- `A=1` e `B=1` (pois `A AND B = 1`), mesmo com `C=1`.

Forma resumida:
\[
F=1 \iff (\overline{C}=1)\ \text{ou}\ (A\cdot B=1)
\]
