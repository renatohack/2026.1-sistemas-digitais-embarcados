# Roteiro de Video - Documento Auxiliar

Nao incluir este arquivo no ZIP final da entrega. Ele e apenas um apoio para a gravacao do video.

## 1. Abertura

### Fala sugerida

"Neste video eu vou demonstrar a resolucao do assessment de DR2 em Assembly AArch64. A organizacao esta separada por questao, com `main.S` e `lib.S`, e a demonstracao sera feita no WSL usando toolchain cruzada, `qemu-aarch64` e `gdb-multiarch`."

### O que mostrar

- a raiz do projeto
- as pastas `q1` a `q12`
- o arquivo do relatorio tecnico

### Comandos

```bash
pwd
ls
find q1 q2 q3 q4 q5 q6 q7 q8 q9 q10 q11 q12 -maxdepth 1 -type f | sort
```

## 2. Estrutura fixa para cada questao

Para cada questao, siga sempre este padrao:

1. mostrar rapidamente `main.S` e `lib.S`
2. abrir o `guide.txt` da pasta
3. executar os comandos exatamente como estao no `guide.txt`
4. mostrar a compilacao com `aarch64-linux-gnu-gcc`
5. mostrar a execucao com `qemu-aarch64`
6. mostrar o `echo $?`
7. iniciar a depuracao com `qemu-aarch64 -g` e `gdb-multiarch`
8. executar os comandos do GDB que estao no `guide.txt`
9. encerrar explicando o que foi validado

Frase curta que voce pode repetir em todas:

"Agora eu vou mostrar o codigo da questao, compilar no WSL, executar no qemu e validar no GDB os registradores e a memoria que o enunciado pede."

## 3. Roteiro por Questao

### q1

#### Fala sugerida

"Na questao 1 eu implementei a normalizacao de amostras PCM de 16 bits para 32 bits, com extensao de sinal, multiplicacao por ganho e saturacao no intervalo de 23 bits."

#### O que mostrar

- `q1/lib.S`
- `q1/main.S`
- `q1/guide.txt`
- no GDB, o vetor `output_samples`

#### Comandos

Use exatamente os comandos de `q1/guide.txt`.

### q2

#### Fala sugerida

"Na questao 2 eu implementei a serie de Taylor do seno em double, com criterio de parada por erro e limite maximo de iteracoes."

#### O que mostrar

- `q2/lib.S`
- `q2/main.S`
- `q2/guide.txt`
- no GDB, os casos `x = 0` e `x = 1.0`

#### Comandos

Use exatamente os comandos de `q2/guide.txt`.

### q3

#### Fala sugerida

"Na questao 3 eu fiz o produto escalar com acumulacao em 64 bits e parada antecipada quando ha overflow do acumulador."

#### O que mostrar

- `q3/lib.S`
- `q3/main.S`
- `q3/guide.txt`
- no GDB, o status de overflow e o acumulador retornado

#### Comandos

Use exatamente os comandos de `q3/guide.txt`.

### q4

#### Fala sugerida

"Na questao 4 eu tratei divisao por zero e o caso extremo `INT64_MIN / -1`, devolvendo saturacao positiva com status especifico."

#### O que mostrar

- `q4/lib.S`
- `q4/main.S`
- `q4/guide.txt`
- no GDB, os dois caminhos de erro

#### Comandos

Use exatamente os comandos de `q4/guide.txt`.

### q5

#### Fala sugerida

"Na questao 5 eu implementei uma conversao de unidades em Q16.16 com selecao por modo e tratamento de modo invalido."

#### O que mostrar

- `q5/lib.S`
- `q5/main.S`
- `q5/guide.txt`
- no GDB, os tres modos validos e o modo invalido

#### Comandos

Use exatamente os comandos de `q5/guide.txt`.

### q6

#### Fala sugerida

"Na questao 6 eu percorri a string byte a byte, convertendo letras maiusculas ASCII para minusculas e contando quantas conversoes foram feitas."

#### O que mostrar

- `q6/lib.S`
- `q6/main.S`
- `q6/guide.txt`
- no GDB, a string final `hello!`

#### Comandos

Use exatamente os comandos de `q6/guide.txt`.

### q7

#### Fala sugerida

"Na questao 7 eu implementei a raiz quadrada por Newton-Raphson, com validacao de entrada negativa e limite de iteracoes."

#### O que mostrar

- `q7/lib.S`
- `q7/main.S`
- `q7/guide.txt`
- no GDB, o caso `sqrt(4.0)` e o erro para `a < 0`

#### Comandos

Use exatamente os comandos de `q7/guide.txt`.

### q8

#### Fala sugerida

"Na questao 8 eu implementei a integracao numerica pela regra do trapezio para um vetor de doubles."

#### O que mostrar

- `q8/lib.S`
- `q8/main.S`
- `q8/guide.txt`
- no GDB, o valor final da integral

#### Comandos

Use exatamente os comandos de `q8/guide.txt`.

### q9

#### Fala sugerida

"Na questao 9 eu implementei a transformacao afim 2D em ponto fixo Q16.16, com modo apenas matricial e modo matricial com translacao."

#### O que mostrar

- `q9/lib.S`
- `q9/main.S`
- `q9/guide.txt`
- no GDB, o vetor `out_mode1`

#### Comandos

Use exatamente os comandos de `q9/guide.txt`.

### q10

#### Fala sugerida

"Na questao 10 eu implementei a media movel em inteiros com acumulador deslizante em 64 bits e politica de borda zerada."

#### O que mostrar

- `q10/lib.S`
- `q10/main.S`
- `q10/guide.txt`
- no GDB, o vetor final `output_vec`

#### Comandos

Use exatamente os comandos de `q10/guide.txt`.

### q11

#### Fala sugerida

"Na questao 11 eu avaliei um polinomio em Q16.16 usando Horner, com saturacao do acumulador e status de estouro."

#### O que mostrar

- `q11/lib.S`
- `q11/main.S`
- `q11/guide.txt`
- no GDB, o caso simples e o caso saturado

#### Comandos

Use exatamente os comandos de `q11/guide.txt`.

### q12

#### Fala sugerida

"Na questao 12 eu integrei um pipeline de diagnostico IMU usando as funcoes anteriores. O fluxo normaliza as amostras, calcula energia, media, magnitude e classifica o estado final."

#### O que mostrar

- `q12/lib.S`
- `q12/main.S`
- `q12/guide.txt`
- no GDB, os checkpoints `after_normalize`, `after_dot`, `after_sqrt` e `after_classify`
- o `echo $?` com valor `2`, representando `FAULT`

#### Comandos

Use exatamente os comandos de `q12/guide.txt`.

## 4. Encerramento

### Fala sugerida

"Com isso eu mostrei a organizacao das questoes, a compilacao no WSL, a execucao no qemu e a validacao no GDB dos principais registradores, vetores e valores de retorno."

### O que lembrar durante a gravacao

- manter a webcam ligada
- mostrar o terminal inteiro
- falar o numero da questao antes de cada demonstracao
- comentar rapidamente o que esta sendo validado em cada breakpoint
