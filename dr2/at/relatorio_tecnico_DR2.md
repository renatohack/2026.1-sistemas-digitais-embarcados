# Relatorio Tecnico - DR2 Assessment

## 1. Escopo

Este material documenta a resolucao dos exercicios `q1` a `q12` do assessment de DR2 - Programacao Assembly ARM 64-bits. A entrega foi organizada conforme o enunciado:

- uma pasta por exercicio: `q1`, `q2`, ..., `q12`
- separacao entre `main.S` e `lib.S`
- geracao de `main.o`, `lib.o` e do executavel de cada questao
- validacao por execucao e por depuracao com GDB nos pontos pedidos pelo enunciado

## 2. Organizacao dos Arquivos

Cada pasta `qX` contem:

- `main.S`: chamador, casos de teste e pontos de parada para validacao
- `lib.S`: implementacao das funcoes exigidas pelo exercicio
- `main.o`: objeto gerado a partir de `main.S`
- `lib.o`: objeto gerado a partir de `lib.S`
- `qX`: executavel final da questao
- `guide.txt`: roteiro de compilacao, execucao e depuracao para gerar evidencias no terminal

Arquivo adicional gerado para a parte de entrega:

- `relatorio_tecnico_DR2.md`: este relatorio

## 3. Ambiente e Compilacao

As evidencias e validacoes deste material foram preparadas para execucao no WSL, usando toolchain cruzada AArch64, `qemu-aarch64` para execucao e `gdb-multiarch` para depuracao remota. Os programas foram escritos como binarios stand-alone em AArch64, com `_start` como ponto de entrada e syscall `exit` no encerramento.

O fluxo padrao de compilacao e execucao documentado nos guias foi:

```bash
aarch64-linux-gnu-gcc -g -c main.S -o main.o
aarch64-linux-gnu-gcc -g -c lib.S -o lib.o
aarch64-linux-gnu-gcc -g -nostdlib -static -no-pie main.o lib.o -o qX
qemu-aarch64 ./qX
```

Para depuracao no WSL, o fluxo documentado foi:

```bash
qemu-aarch64 -g 2401 ./qX &
gdb-multiarch -q ./qX
```

## 4. Atendimento a ABI e Requisitos Tecnicos

As solucoes foram escritas seguindo a AAPCS64:

- parametros inteiros e ponteiros recebidos em `x0` a `x7` ou `w0` a `w7`
- parametros `double` recebidos em `d0`, `d1`, etc.
- valores de retorno devolvidos nos registradores definidos pelo enunciado
- stack mantida alinhada em 16 bytes quando necessario
- funcoes leaf mantidas sem uso desnecessario de stack
- registradores callee-saved inteiros ou FP preservados quando seu uso seria necessario

Tambem foram atendidos os requisitos funcionais do enunciado:

- uso explicito de comparacoes e branches
- lacos implementados diretamente em Assembly
- acesso explicito a memoria via `ldr`, `str`, `ldrb`, `strb`, `ldrsh`
- uso de aritmetica inteira, ponto fixo e ponto flutuante conforme cada exercicio
- validacoes de erro retornando status coerente

## 5. Descricao Tecnica por Exercicio

### q1 - `normalize_saturate_i16_to_i32`

Foi implementada a normalizacao de amostras PCM `int16_t` para `int32_t`, com extensao de sinal, multiplicacao por ganho inteiro e saturacao no intervalo `[-2^23, 2^23-1]`. A funcao trata `ponteiro nulo` e `N == 0` antes do loop principal.

No `main.S`, foram preparados casos com valores extremos, inclusive `32767` e `-32768`, alem de chamadas extras para validar os status `1` e `2`. A memoria do vetor de saida foi preparada para inspecao no GDB.

### q2 - `sin_taylor`

A funcao foi implementada em `double`, acumulando a serie de Taylor do seno enquanto `fabs(termo) >= eps` e enquanto o numero maximo de iteracoes nao foi atingido. Foram tratados os casos `eps <= 0` e `max_iter == 0`.

O `main.S` valida `x = 0`, `x = 1.0`, `eps invalido` e `max_iter = 0`, registrando resultados para comparacao posterior e inspecao em GDB.

### q3 - `dot_i32_checked`

O produto escalar foi implementado com leitura de dois vetores `int32_t`, multiplicacao com extensao para 64 bits via `smull` e acumulacao em `int64_t`. O overflow do acumulador e detectado via `adds` e flag de overflow, com early-exit imediato.

O `main.S` contem um caso simples com resultado conhecido e um caso proposital para overflow, permitindo confirmar no GDB o ponto de parada e o valor do acumulador retornado.

### q4 - `safe_div_s64`

A divisao assinada segura trata explicitamente:

- divisor igual a zero, retornando saturacao positiva e status `1`
- caso `INT64_MIN / -1`, retornando saturacao positiva e status `2`
- divisao normal com `sdiv` e status `0`

O `main.S` cobre os tres caminhos.

### q5 - `convert_speed_q16`

Foi implementada uma selecao por modo equivalente a um `switch`, com tres conversoes em Q16.16:

- `0`: km/h para m/s
- `1`: m/s para km/h
- `2`: knots para m/s

As contas intermediarias usam 64 bits e `udiv`. O caso default retorna valor zero e status `1`.

### q6 - `to_lower_ascii_inplace`

A funcao percorre a string byte a byte ate `0x00`, converte apenas caracteres ASCII `A` a `Z` para minusculas e contabiliza quantas substituicoes foram feitas. O caso de ponteiro nulo retorna contador zero e status `1`.

O `main.S` usa a string `"HeLLo!"`, valida o contador `3` e permite inspecionar a string final `"hello!"` no GDB.

### q7 - `sqrt_nr`

Foi implementada a aproximacao de raiz quadrada via Newton-Raphson em `double`, com:

- erro para `a < 0`
- erro para `max_iter == 0`
- chute inicial `a` para `a >= 1`
- chute inicial `1.0` para `a < 1`

O laco roda exatamente `max_iter` vezes.

### q8 - `trapz_energy_f64`

A integracao numerica pela regra do trapezio foi implementada em `double`, com validacao de:

- ponteiro nulo
- `N < 2`
- `dt <= 0`

O laco acessa explicitamente `f[i]` e `f[i+1]`, acumulando `(f[i] + f[i+1]) * dt * 0.5`.

### q9 - `affine2d_q16`

Foi implementada a transformacao afim 2D em Q16.16 com `switch` de dois modos:

- `mode 0`: `out = A * p`
- `mode 1`: `out = A * p + b`

As multiplicacoes usam 64 bits intermediarios, seguidas de normalizacao por shift de 16 bits. Todos os ponteiros sao validados antes do processamento.

### q10 - `moving_avg_i32`

A media movel foi implementada com acumulador deslizante em 64 bits. Para `i < W - 1`, a saida recebe zero. A partir da janela completa, a rotina faz:

- soma do novo elemento `in[i]`
- subtracao explicita de `in[i-W]` quando aplicavel
- divisao inteira pelo tamanho da janela

Sao tratados os casos de ponteiro nulo, `N == 0` e `W` invalido.

### q11 - `poly_horner_q16_sat`

A avaliacao polinomial em Q16.16 foi feita pelo metodo de Horner:

`acc = coef[0]`

`acc = ((acc * x) >> 16) + coef[i]`

O acumulador e saturado em `[-2^31, 2^31-1]`, com status `3` quando a saturacao ocorre. O `main.S` testa tanto um caso simples quanto um caso que satura.

### q12 - Mini-projeto do pipeline IMU

O `main.S` integra as funcoes:

- `normalize_saturate_i16_to_i32`
- `dot_i32_checked`
- `safe_div_s64`
- `sqrt_nr`
- `classify_health`

O pipeline faz:

1. normalizacao das amostras `int16_t`
2. calculo da energia via produto escalar do vetor normalizado com ele mesmo
3. calculo da media via divisao segura por `N`
4. conversao explicita para `double`
5. calculo da magnitude via `sqrt_nr`
6. classificacao final por `switch`

Foi adotada uma bitmask de flags para propagacao de erros:

- bit 0: ponteiro nulo
- bit 1: `N` invalido
- bit 2: erro de divisao ou erro numerico equivalente
- bit 3: overflow ou saturacao relevante para diagnostico

No caso de teste preparado, o vetor gera saturacao ja na normalizacao. Por isso a classificacao final retorna `FAULT`, e o executavel encerra com `exit code 2`, que e exatamente o comportamento esperado para o caso configurado.

## 6. Validacao Executada

As validacoes realizadas cobriram dois niveis:

- execucao dos binarios no WSL com `qemu-aarch64`, para checar `exit code`
- depuracao com `gdb-multiarch` conectado ao stub remoto do `qemu-aarch64 -g`, para inspecionar registradores e memoria nos pontos pedidos

Resumo dos `exit codes` finais:

- `q1` a `q11`: `0`
- `q12`: `2`

Resumo dos principais checkpoints observados no GDB:

- `q1`: vetor de saida `8388607, -8388608, 617000, -8388608, 0`
- `q2`: `sin(0) = 0` e `sin(1.0) ~= 0.8414709848078937`
- `q3`: status `3` com acumulador `9223372028264841218`
- `q4`: saturacao positiva para divisor zero e para `INT64_MIN / -1`
- `q5`: tres modos validos e um modo invalido com status `1`
- `q6`: string final `"hello!"` e contador `3`
- `q7`: `sqrt(4.0) = 2.0`, erro para `a < 0`
- `q8`: integral `2.0` para `[0, 1, 2]` com `dt = 1`
- `q9`: saida `(3, 4)` em Q16.16 para `A = I`, `b = (1,1)`, `p = (2,3)`
- `q10`: saida `[0, 1, 2, 3]` com `W = 2`
- `q11`: valor `45 << 16 = 2949120` e saturacao em `2147483647`
- `q12`: vetor normalizado, energia, magnitude e codigo final `2` confirmados em GDB

## 7. Decisoes de Engenharia

Algumas decisoes foram tomadas para manter o codigo simples, deterministico e facil de depurar:

- uso de `_start` e syscall `exit` em vez de `main` com libc
- testes embutidos em `main.S` para reduzir dependencia externa
- labels de checkpoint no `main.S` para facilitar breakpoints no GDB
- validacoes internas por comparacao com resultados esperados, encerrando com `exit code 0` ou `1` quando a questao e apenas de unidade
- no `q12`, retorno do codigo de diagnostico real do pipeline como `exit code`

## 8. O que Ainda Precisa Ser Feito Manualmente

Para concluir a entrega final, ainda dependem de execucao manual:

- exportar este relatorio para PDF e renomear para `nome_sobrenome_DR2_AT.PDF`
- gerar os prints do terminal conforme os `guide.txt`, no WSL com `qemu-aarch64` e `gdb-multiarch`
- capturar as evidencias pedidas pelo professor
- gravar o video com webcam e tela
- subir o video para o YouTube como nao listado
- montar o ZIP final com todos os arquivos
