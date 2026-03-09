# Aula Completa: SOP, POS, Karnaugh e Expressao Minima (com porques)

## 1. Respostas diretas das suas duvidas

### 1.1 SOP usa as linhas com F=1? POS usa as linhas com F=0?
Sim.

- SOP (Soma de Produtos) canonica usa as linhas onde `F=1`.
- POS (Produto de Somas) canonica usa as linhas onde `F=0`.

**Por que?**

- Um **mintermo** vale 1 em exatamente uma linha da tabela verdade.
- Se voce fizer OR (`+`) dos mintermos das linhas onde F=1, voce reconstrui exatamente os 1s da funcao.
- Um **maxtermo** vale 0 em exatamente uma linha da tabela verdade.
- Se voce fizer AND (produto) dos maxtermos das linhas onde F=0, voce reconstrui exatamente os 0s da funcao.

Ou seja: SOP modela o conjunto dos 1s; POS modela o conjunto dos 0s.

### 1.2 O que e mapa de Karnaugh? Para que serve?
E uma forma visual de simplificar funcoes booleanas.

Serve para:

- reduzir quantidade de portas logicas,
- reduzir custo de hardware,
- diminuir atrasos de propagacao,
- chegar numa expressao mais simples de implementar em Verilog.

### 1.3 O que significa "cancela" na expressao minimizada?
Significa que uma variavel some porque ela aparece com e sem complemento dentro do mesmo grupo.

Exemplo:

```text
AB + A'B = B(A + A') = B*1 = B
```

`A` cancelou, ficou so `B`.

---

## 2. Notacao basica (o que aparece no relatorio)

- `A'` = NOT A
- `AB` = A AND B
- `A + B` = A OR B
- `F(A,B,C)` = saida F em funcao de A, B, C
- `Sm(1,3,5,7)` = soma dos mintermos 1, 3, 5, 7

Indices decimais para 3 variaveis:

- 0->000, 1->001, 2->010, 3->011, 4->100, 5->101, 6->110, 7->111

---

## 3. SOP e POS com o seu exemplo do TP

Funcao do TP:

```text
F(A,B,C) = Sm(1,3,5,7)
```

### 3.1 SOP canonica (usa F=1)
Linhas 1,3,5,7:

- 1 = 001 -> `A'B'C`
- 3 = 011 -> `A'BC`
- 5 = 101 -> `AB'C`
- 7 = 111 -> `ABC`

Entao:

```text
F = A'B'C + A'BC + AB'C + ABC
```

### 3.2 POS canonica (usa F=0)
Linhas 0,2,4,6:

- 0 = 000 -> `(A + B + C)`
- 2 = 010 -> `(A + B' + C)`
- 4 = 100 -> `(A' + B + C)`
- 6 = 110 -> `(A' + B' + C)`

Entao:

```text
F = (A + B + C)(A + B' + C)(A' + B + C)(A' + B' + C)
```

---

## 4. Karnaugh: como interpretar

Para 3 variaveis, use:

- linhas: `AB` em Gray code: `A'B'`, `A'B`, `AB`, `AB'`
- colunas: `C'` e `C`

Tabela do seu TP:

| AB \\ C | C' | C |
|---|---|---|
| A'B' | 0 | 1 |
| A'B  | 0 | 1 |
| AB   | 0 | 1 |
| AB'  | 0 | 1 |

Interpretacao:

- toda coluna `C` esta com 1,
- isso forma um grupo de 4 celulas,
- no grupo, A e B variam (cancelam),
- C fica fixo em 1,
- resultado: `F = C`.

---

## 5. Regras de agrupamento no Karnaugh

Para minimizar SOP:

- agrupe **1s**.

Para minimizar POS:

- agrupe **0s**.

Regras gerais:

1. tamanhos de grupo: 1, 2, 4, 8... (potencias de 2)
2. grupos maiores sao melhores
3. todos os 1s (ou 0s) relevantes devem ser cobertos
4. pode sobrepor grupos se ajudar a simplificar
5. bordas se conectam (wrap-around)
6. diagonal nao e adjacencia

---

## 6. Outro exemplo completo (mais explicado)

Vamos usar:

```text
G(A,B,C) = Sm(1,2,3,5,7)
```

### 6.1 Tabela verdade (resumo)
G=1 em: 1,2,3,5,7  
G=0 em: 0,4,6

### 6.2 SOP canonica

```text
G = A'B'C + A'BC' + A'BC + AB'C + ABC
```

### 6.3 POS canonica
Zeros em 0,4,6:

```text
G = (A + B + C)(A' + B + C)(A' + B' + C)
```

### 6.4 Karnaugh desse exemplo

| AB \\ C | C' | C |
|---|---|---|
| A'B' | 0 | 1 |
| A'B  | 1 | 1 |
| AB   | 0 | 1 |
| AB'  | 0 | 1 |

Agrupamentos SOP (1s):

- Grupo de 4 na coluna `C` -> termo `C`
- Grupo de 2 na linha `A'B` (colunas C' e C) -> termo `A'B`

Expressao minimizada:

```text
G = C + A'B
```

### 6.5 Onde aconteceu o "cancela"
No grupo da linha `A'B`, as duas celulas sao:

- `A'BC'`
- `A'BC`

Somando:

```text
A'BC' + A'BC = A'B(C' + C) = A'B*1 = A'B
```

`C` cancelou.

---

## 7. Para que isso serve na pratica (FPGA/Verilog)

Quando voce minimiza:

- usa menos LUTs e menos logica,
- o circuito tende a ficar mais eficiente,
- o codigo Verilog fica mais limpo.

Exemplo:

- antes: `F = A'B'C + A'BC + AB'C + ABC`
- depois: `F = C`

Em Verilog:

```verilog
assign F = C;
```

---

## 8. Check rapido para estudo

1. SOP canonica: uso os 1s ou os 0s?
2. POS canonica: uso os 1s ou os 0s?
3. No Karnaugh para SOP, agrupo 1s ou 0s?
4. Por que `AB + A'B = B`?
5. Se uma variavel varia dentro do grupo, ela fica ou cancela?

Se voce responder essas 5 com seguranca, essa parte do TP esta dominada.
