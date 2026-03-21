Chegamos ao momento de avaliar o conhecimento construído ao longo da disciplina **DR2 – Programação Assembly ARM 64-bits**.

Durante a disciplina, você aprendeu a estruturar programas stand-alone em **AArch64**, manipular memória com segurança, controlar fluxo com branches e, principalmente, **implementar funções e operações aritméticas respeitando a ABI (AAPCS64)**.

Agora, você irá aplicar esses conhecimentos em **12 exercícios práticos (avançados)** que simulam rotinas reais de **firmware embarcado** em aplicações de engenharia como **pré-processamento de sinais**, **cálculo numérico controlado**, **conversão e calibração de medições** e **diagnóstico de integridade de sensores**. Em todos eles, você deverá separar rigorosamente o código em **main.S (chamador)** e **lib.S (funções)**, executar no **Raspberry Pi Zero 2W (Cortex-A53)** e validar o comportamento com **GDB** e com o **código de retorno do processo**, como se estivesse entregando um módulo crítico para integração em um sistema de bordo.

## Exercício 1
**Rotina de Saturação e Normalização de Amostras (PCM 16-bit)**

**Contexto**

Em um projeto de engenharia da computação para aquisição de áudio, é comum receber amostras PCM de 16 bits vindas de um ADC e precisar normalizá-las para um pipeline interno de 32 bits. Em placas embarcadas como o Raspberry Pi Zero 2W, a normalização costuma ser feita em rotinas de baixo nível, com regras rígidas de saturação para evitar overflow e distorções graves. O firmware recebe blocos de amostras e aplica: (1) extensão de sinal para 32 bits, (2) multiplicação por um ganho inteiro, (3) saturação no intervalo permitido e (4) acumulação de estatísticas (mínimo, máximo) para diagnóstico. Você deverá implementar essa rotina como função, respeitando ABI, usando memória para ler/gravar amostras e controlando o fluxo com comparações e branches. O objetivo final é produzir um bloco de saída consistente, além de permitir validação determinística via GDB.

**Exemplo numérico**

  - entrada: sample = -20000, gain = 500
  - produto: -20000 * 500 = -10.000.000
  - saturação em `[-2^23, 2^23-1] = [-8.388.608, 8.388.607]` ⇒ saída: -8.388.608

**Tarefa**

Implemente em lib.S a função normalize_saturate_i16_to_i32:

  - **Entrada (AAPCS64):**
      - x0 = ponteiro para vetor de int16_t (entrada)
      - x1 = ponteiro para vetor de int32_t (saída)
      - x2 = número de amostras (N)
      - w3 = ganho inteiro (ex: 3, 5, 7)
  - **Saída:**
      - w0 = código de status (0 = OK, 1 = N=0, 2 = ponteiro nulo)

**Regras:**

  - Se x0==0 ou x1==0 ⇒ retorne status 2.
  - Se N==0 ⇒ retorne status 1.
  - Para cada amostra:
      - faça extensão de sinal para 32 bits
      - multiplique pelo ganho
      - **sature** o resultado em `[-2^23, 2^23-1]` (simula headroom interno)
      - grave no vetor de saída
  - Use **laço** (while/for em Assembly) e **comparações**.

**Requisitos Técnicos e Saídas Esperadas**

  - **Especificações de Projeto:**
      - Stack alinhada em 16 bytes.
      - Preserve x19–x28 se usados no loop.
  - **Comportamento esperado da CPU:**
      - Loop reduz x2 até zero.
      - Saturação via comparações (cmp + b.lt/b.gt) antes do str.
  - **Critério de Validação (GDB):**
      - Em main.S, carregue um vetor com valores extremos (ex: 32767, -32768) e ganho alto.
      - Verifique memória de saída (x1) e o status em w0.

## Exercício 2
**Série de Taylor para Seno (Aproximação Controlada por Erro)**

**Contexto**

Em navegação inercial e estabilização, sensores fornecem ângulos pequenos em radianos e, por desempenho e determinismo, o firmware pode usar aproximações polinomiais ao invés de bibliotecas de ponto flutuante complexas. Uma técnica clássica é a série de Taylor do seno, somando termos até que o termo corrente fique abaixo de um limiar de erro. Em ARM64, isso exige controle cuidadoso de registradores FP (d0–d31), preservação conforme ABI e um loop com condição de parada robusta. Seu objetivo é implementar uma função que calcula `sin(x)` aproximado, somando termos `(-1)^k * x^(2*k+1) / (2*k+1)!` até `|termo| < eps` ou até um número máximo de iterações. O desafio é manter o cálculo estável e validável, lidando com casos de borda (eps muito pequeno, max_iter=0) e retornando um status confiável para o chamador.

**Exemplo numérico:**

Para x = 0.5:

  - `termo_0 = 0.5`
  - `termo_1 = -(0.5^3) / 3! ~= -0.020833`
  - `termo_2 ~= +(0.5^5) / 5! ~= +0.000260`
  - soma parcial `~= 0.479427` (já muito próxima do real)

**Tarefa**

Implemente em lib.S a função sin_taylor:

  - **Entrada:**
      - d0 = x (double)
      - d1 = eps (double, > 0)
      - w0 = max_iter (unsigned)
  - **Saída:**
      - d0 = aproximação de `sin(x)`
      - w1 = status (0=OK, 1=eps inválido, 2=max_iter=0)

**Regras:**

  - Se eps <= 0 ⇒ status 1 e retorne d0=0.0.
  - Se max_iter==0 ⇒ status 2 e retorne d0=0.0.
  - Use **loop** e **comparação** em FP para parada: fabs(termo) < eps.

**Requisitos Técnicos e Saídas Esperadas**

  - **Especificações de Projeto:**
      - Preserve v8–v15 se você os usar (callee-saved FP/SIMD).
      - Mantenha stack alinhada.
  - **Comportamento esperado da CPU:**
      - Iteração atualiza termo e soma acumulada.
      - Branch condicional baseado em comparação FP.
  - **Critério de Validação:**
      - Em main.S, teste x=0, `x ~= 1.0`, e compare com valores esperados aproximados (ex: `sin(0)=0`).
      - Verifique status em w1.

## Exercício 3
**Produto Escalar (Dot Product) com Tratamento de Overflow e Early-Exit**

**Contexto**

Em processamento de sinais e filtros FIR, uma operação central é o **produto escalar** entre duas sequências de inteiros. Em sistemas embarcados, overflow silencioso pode gerar instabilidade e resultados impossíveis de depurar. Uma estratégia realista é: acumular em 64 bits, detectar overflow de acumulação e abortar cedo com um status específico. Você implementará um dot product de vetores int32_t, retornando a soma em 64 bits e um código de status. O exercício exige leitura de memória com offsets, laço eficiente, multiplicação inteira e comparação/branch para controle de erro. Além disso, você deverá validar em GDB que o acumulador e o contador de iterações se comportam corretamente e que o early-exit acontece no ponto certo. Essa rotina simula um módulo de diagnóstico em firmware de áudio/telemetria.

**Exemplo numérico:**

A = [30000, 30000], B = [30000, 30000]

  - parcial: 30000*30000 = 900.000.000
  - soma: 900.000.000 + 900.000.000 = 1.800.000.000 (cresce rápido; em cenários maiores pode exceder limites definidos ⇒ early-exit)

**Tarefa**

Implemente em lib.S a função dot_i32_checked:

  - **Entrada:**
      - x0 = ponteiro vetor A (int32_t)
      - x1 = ponteiro vetor B (int32_t)
      - x2 = N (número de elementos)
  - **Saída:**
      - x0 = soma acumulada (int64)
      - w1 = status (0=OK, 1=N=0, 2=ponteiro nulo, 3=overflow detectado)

**Regras:**

  - Se ponteiros nulos ⇒ status 2.
  - Se N==0 ⇒ status 1.
  - Faça loop em N:
      - acc += (int64)a[i] * (int64)b[i]
      - Se detectar overflow do acumulador, pare imediatamente e retorne ao status 3.
  - Use **comparação/branch** e **laço**.

**Requisitos Técnicos e Saídas Esperadas**

  - **Especificações de Projeto:**
      - Use smull/mul apropriado e acumule em 64 bits.
      - Preserve registradores callee-saved usados.
  - **Comportamento esperado da CPU:**
      - Early-exit via `b.<cond>` quando overflow ocorrer.
  - **Critério de Validação:**
      - Em main.S, crie vetores que forcem overflow (valores altos) e confirme status 3.
      - Verifique x0 (acc) no retorno.

## Exercício 4
**Divisão Segura com Política de Erros (Divisão por Zero e Saturação)**

**Contexto**

Em rotinas de conversão de unidades e estimativas de taxa (ex: pulsos por segundo), a divisão inteira aparece constantemente. Em firmware robusto, dividir por zero não pode “apenas acontecer”: precisa produzir um resultado definido e um status que o sistema use para fallback. Neste exercício, você implementará uma função de divisão segura, com política explícita: (1) se divisor for zero, retorne status e um valor saturado; (2) para divisão assinada, trate o caso extremo INT64_MIN / -1 para evitar overflow. Esse é um padrão real em módulos de diagnóstico e telemetria que precisam continuar operando com sensores defeituosos. Você deverá codificar branches para os casos de borda e usar instruções de divisão (sdiv e/ou udiv) corretamente, mantendo ABI impecável e validação por casos de teste.

**Exemplo numérico:**

  - entrada: x0=1000, x1=0
  - política: divisor zero ⇒ retorno 0x7FFF_FFFF_FFFF_FFFF, status 1

**Tarefa**

Implemente em lib.S a função safe_div_s64:

  - **Entrada:**
      - x0 = numerador (int64)
      - x1 = denominador (int64)
  - **Saída:**
      - x0 = quociente (int64)
      - w1 = status (0=OK, 1=divisor zero, 2=overflow evitado)

**Política**:

  - Se x1==0: retorne x0 = 0x7FFF_FFFF_FFFF_FFFF (saturação positiva) e status 1.
  - Se x0==INT64_MIN e x1==-1: retorne x0 = 0x7FFF_FFFF_FFFF_FFFF e status 2.
  - Caso contrário: x0 = x0 / x1 (assinada) e status 0.
  - Deve haver **comparações e branches** explícitos.

**Requisitos Técnicos e Saídas Esperadas**

  - **Especificações de Projeto:**
      - Função leaf é permitida, mas ABI deve estar correta (se usar stack, alinhe).
  - **Comportamento esperado da CPU:**
      - Paths de erro desviam antes de sdiv.
  - **Critério de Validação:**
      - Em main.S, chame com divisor 0 e confirme status e saturação.
      - Teste INT64_MIN / -1.

## Exercício 5
**Conversão de Unidades com Seleção por Modo**

**Contexto**

Sistemas embarcados frequentemente precisam converter medidas de sensores para unidades padronizadas. Por exemplo, um módulo de navegação pode receber velocidade em km/h, m/s ou nós, dependendo do sensor/configuração. Em Assembly, isso se traduz em uma função que recebe um valor e um “modo” e aplica uma fórmula diferente para cada caso. Para engenharia confiável, o código precisa usar uma decisão múltipla (switch) com comportamento bem definido para modos inválidos. Você implementará uma conversão inteira com aritmética de ponto fixo (sem bibliotecas), usando um **switch via branches sequenciais ou tabela de salto**. O foco é organização, ABI e validação: o chamador vai conferir resultados e status, e modos inválidos devem retornar erro sem corromper registradores.

**Exemplo numérico:**

  - mode 0 (km/h→m/s): 36 km/h ⇒ `36 * 1000 / 3600 = 10` m/s

**Tarefa**

Implemente em lib.S a função convert_speed_q16 (ponto fixo Q16.16):

  - **Entrada:**
      - w0 = mode (0=km/h→m/s, 1=m/s→km/h, 2=knots→m/s)
      - w1 = valor em Q16.16 (unsigned)
  - **Saída:**
      - w0 = valor convertido em Q16.16
      - w2 = status (0=OK, 1=modo inválido)

**Regras:**

  - Use **switch**:
      - mode 0: m/s = km/h * 1000 / 3600
      - mode 1: km/h = m/s * 3600 / 1000
      - mode 2: m/s = knots * 1852 / 3600
  - Faça a conta em 64 bits internamente para evitar overflow.
  - Se mode inválido: retorne valor 0 e status 1.

**Requisitos Técnicos e Saídas Esperadas**

  - **Especificações de Projeto:**
      - Use udiv para divisões.
      - Preserve callee-saved se usar.
  - **Comportamento esperado da CPU:**
      - Branch para cada caso; modo default retorna erro.
  - **Critério de Validação:**
      - Em main.S, teste os 3 modos e um modo inválido (ex: 99) e observe w2.

## Exercício 6
**String Lowercase com Regras ASCII e Contador de Conversões**

**Contexto**

Em telemetria e protocolos simples, é comum normalizar strings para evitar divergências de parsing (“STATUS=OK” vs “status=ok”). Em ambientes bare-metal/stand-alone, essa normalização precisa ser feita sem libc, percorrendo bytes e aplicando regras ASCII. Você implementará uma rotina que converte caracteres A–Z para a–z in-place, interrompendo no byte 0x00. Além da conversão, a função deve contar quantos caracteres foram alterados e retornar esse contador ao chamador. Isso exige manipulação de memória byte a byte, comparações e branches, e um loop robusto. Para validar como engenheiro, você deverá inspecionar a string antes/depois no GDB e confirmar o contador retornado, garantindo que a função não ultrapasse o terminador nem corrompa registradores indevidos.

**Exemplo numérico:**

  - entrada: "HeLLo!"
  - saída: "hello!"
  - convertidos: 3

**Tarefa**

Implemente em lib.S a função to_lower_ascii_inplace:

  - **Entrada:**
      - x0 = ponteiro para string ASCII terminada em 0x00
  - **Saída:**
      - w0 = número de caracteres convertidos
      - w1 = status (0=OK, 1=ponteiro nulo)

**Regras:**

  - Se x0==0: retorne w0=0 e status 1.
  - Loop byte a byte:
      - pare ao encontrar 0x00
      - se 'A' <= c <= 'Z', faça c += 32, grave de volta e incremente contador
  - Obrigatório usar **laço** e **comparações**.

**Requisitos Técnicos e Saídas Esperadas**

  - **Especificações de Projeto:**
      - Pode ser leaf function; cuide de ABI.
  - **Comportamento esperado da CPU:**
      - ldrb/strb com pós-incremento ou offset.
  - **Critério de Validação:**
      - Em main.S, use "HeLLo!" e confirme string final "hello!" e contador 3.

## Exercício 7
**Newton-Raphson para Raiz Quadrada (Double) com Parada por Iterações**

**Contexto**

Em cálculo numérico embarcado (por exemplo, magnitude de vetor em navegação e filtros), a raiz quadrada aparece frequentemente. Mesmo com FP disponível, você pode precisar de uma implementação determinística e controlada, usando Newton-Raphson: `x_(n+1) = 0.5 * (x_n + a / x_n)`. O desafio real é lidar com entradas inválidas (a < 0), entradas pequenas, e evitar divisão por zero quando o chute inicial for inadequado. Você implementará uma função sqrt_nr em double, com limite de iterações e status de erro. O chamador fornecerá o número e max_iter, e a função deverá retornar uma aproximação e um status. O exercício força uso correto de registradores FP, branches para casos de borda e um loop com condição por contagem (while). A validação será feita com valores conhecidos e inspeção de d0 no retorno.

**Exemplo numérico:**

**Caso de teste**

  - **`a = 10.0`**
  - chute inicial: como **`a >= 1`**, use **`x_0 = 10.0`**
  - objetivo: aproximar **`sqrt(10) ~= 3.162277`**

**Iterações**

**n = 0**

  - `x_0 = 10.0`
  - `a / x_0 = 10 / 10 = 1.0`
  - `x_1 = 0.5 * (10.0 + 1.0) = 5.5`

**n = 1**

  - `x_1 = 5.5`
  - `a / x_1 ~= 10 / 5.5 ~= 1.8181818`
  - `x_2 = 0.5 * (5.5 + 1.8181818) ~= 3.6590909`

**n = 2** ⇒ `~= 3.19566565`  
**n = 3** ⇒ `~= 3.16227...`

**Tarefa**

Implemente em lib.S a função sqrt_nr:

  - **Entrada:**
      - d0 = a (double)
      - w0 = max_iter
  - **Saída:**
      - d0 = aproximação de `sqrt(a)`
      - w1 = status (0=OK, 1=a<0, 2=max_iter=0)

**Regras:**

  - Se a < 0: retorne d0=0.0 e status 1.
  - Se max_iter==0: retorne d0=0.0 e status 2.
  - Chute inicial: use x0 = a se a >= 1, senão x0 = 1.0 (para evitar divisão por zero).
  - Itere max_iter vezes (loop), usando FP divide e multiply.

**Requisitos Técnicos e Saídas Esperadas**

  - **Especificações de Projeto:**
      - Preserve v8–v15 se usados.
  - **Comportamento esperado da CPU:**
      - Contador decrementa; branch encerra ao zerar.
  - **Critério de Validação:**
      - Teste a=4.0 (esperado ~2.0) e a=-1.0 (erro).

## Exercício 8
**Integração Numérica (Regra do Trapézio) para Energia de Sinal**

**Contexto**

Ao estimar energia consumida ou energia de um sinal, uma prática comum é integrar numericamente uma curva amostrada. Em áudio, por exemplo, você pode integrar a potência ao longo do tempo para obter energia aproximada. Em sistemas embarcados, a regra do trapézio é simples e eficaz: `integral f(t) dt ~= sum ((f[i] + f[i+1]) / 2) * dt`. Você implementará essa integração usando ponto fixo ou double (escolha especificada), com tratamento para N insuficiente e dt inválido. O desafio é percorrer o vetor, somar com estabilidade e retornar status coerente. O exercício exige leitura com offsets (acessar f[i] e f[i+1] explicitamente), loop e comparações para validar parâmetros. Como validação, o chamador usará um vetor curto com valores conhecidos, e você deverá demonstrar no GDB o acumulador evoluindo e o resultado final no registrador de retorno.

**Exemplo numérico:**

  - `f = [0, 1, 2]`, `dt = 1`
  - `integral ~= (0+1) / 2 * 1 + (1+2) / 2 * 1 = 0.5 + 1.5 = 2.0`

**Tarefa**

Implemente em lib.S a função trapz_energy_f64:

  - **Entrada:**
      - x0 = ponteiro para vetor de double f[]
      - x1 = N (número de amostras)
      - d0 = dt (double)
  - **Saída:**
      - d0 = integral aproximada
      - w0 = status (0=OK, 1=ponteiro nulo, 2=N<2, 3=dt<=0)

**Regras:**

  - Se x0==0 ⇒ status 1.
  - Se N<2 ⇒ status 2.
  - Se dt<=0 ⇒ status 3.
  - Loop i=0..N-2:
      - leia f[i] e f[i+1]
      - acumule `(f[i] + f[i+1]) * dt * 0.5`
  - Obrigatório: **laço** e **comparações** (incluindo FP para dt).

**Requisitos Técnicos e Saídas Esperadas**

  - **Especificações de Projeto:**
      - Acesso a f[i] e f[i+1] via offsets claros (ex: #0, #8, etc.).
  - **Comportamento esperado da CPU:**
      - Acumulador em FP cresce; contador controla loop.
  - **Critério de Validação:**
      - Vetor simples [0,1,2], dt=1 ⇒ integral ~2.0 (trapézio).

## Exercício 9
**Função Afim Matricial 2D (Álgebra Linear) com Seleção de Operação**

**Contexto**

Transformações 2D são comuns em visão computacional embarcada e em pipelines de mapeamento (ex: rotacionar e transladar coordenadas de um sensor). Uma transformação afim pode ser expressa por `p' = A * p + b`, onde A é 2x2 e b é vetor 2D. Mesmo em sistemas simples, é comum suportar diferentes modos de operação: aplicar apenas a rotação/escala (A·p), aplicar completa (A·p+b), ou aplicar inversa aproximada quando o modo exige correção rápida. Você implementará uma função que recebe A, b, p (todos em ponto fixo Q16.16) e um mode que escolhe a operação (switch). O exercício exige multiplicação, soma, divisão por escala (se necessário), uso de 64 bits intermediários, e um switch robusto para modos inválidos. A validação ocorrerá comparando resultados para entradas simples e checando status.

**Exemplo numérico:**

Com `A = I`, `b = (1,1)`, `p = (2,3) => p' = (3,4)`.

**Tarefa**

Implemente em lib.S a função affine2d_q16:

  - **Entrada:**
      - w0 = mode (0=A·p, 1=A·p+b)
      - x1 = ponteiro para A (4 int32 Q16.16: a00,a01,a10,a11)
      - x2 = ponteiro para b (2 int32 Q16.16: b0,b1)
      - x3 = ponteiro para p (2 int32 Q16.16: x,y)
      - x4 = ponteiro para out (2 int32 Q16.16)
  - **Saída:**
      - w0 = status (0=OK, 1=ponteiro nulo, 2=modo inválido)

**Regras:**

  - Se qualquer ponteiro for nulo ⇒ status 1.
  - Switch em mode:
      - mode 0: out = A·p
      - mode 1: out = A·p + b
      - default: status 2
  - Use 64 bits intermediários e normalize de volta para Q16.16 (shift apropriado).
  - Obrigatório: **switch** + operações aritméticas.

**Requisitos Técnicos e Saídas Esperadas**

  - **Especificações de Projeto:**
      - Acesso explícito aos 4 coeficientes e às 2 componentes do vetor.
  - **Comportamento esperado da CPU:**
      - Branch para casos do mode; grava em out.
  - **Critério de Validação:**
      - Use A=I e b=(1,1) em Q16.16; verifique out.

## Exercício 10
**Média Móvel (Rolling) em Inteiros com Janela e Tratamento de Bordas**

**Contexto**

Em filtragem de sensores (temperatura, aceleração, nível), uma técnica simples e eficiente é a **média móvel**. A janela suaviza ruído, mas exige cuidado para bordas: nos primeiros elementos, a janela ainda não está cheia, e você precisa definir uma política (ex: usar janela parcial ou retornar erro). Em sistemas críticos, políticas devem ser explícitas e testáveis. Você implementará uma função que calcula a média móvel de um vetor int32_t e grava em um vetor de saída int32_t, usando uma janela W. O exercício exige manipulação de ponteiros, loop, divisões inteiras e comparações para validação de parâmetros e bordas. Você também deverá implementar uma política: para i < W-1, a saída deve ser 0 (ou outro valor definido) e a média começa apenas quando a janela está completa. A validação será feita verificando saídas e observando o acumulador deslizante em registradores no GDB.

**Exemplo numérico:**

Entrada [1,2,3,4], W=2 ⇒ saída [0,1,2,3] (média inteira truncada).

**Tarefa**

Implemente em lib.S a função moving_avg_i32:

  - **Entrada:**
      - x0 = ptr in (int32)
      - x1 = ptr out (int32)
      - x2 = N
      - w3 = W (tamanho da janela, 1..N)
  - **Saída:**
      - w0 = status (0=OK, 1=ponteiro nulo, 2=N=0, 3=W inválido)

**Política:**

  - Para i < W-1, grave 0 em out[i].
  - Para i >= W-1, grave avg = sum(in[i-W+1..i]) / W.

**Obrigatório:**

  - Loop principal e comparações para bordas.
  - Você deve **explicitar** em código o acesso a in[i] e in[i-W] (para somatório deslizante).

**Requisitos Técnicos e Saídas Esperadas**

  - **Especificações de Projeto:**
      - Somatório em 64 bits; use sdiv/udiv conforme sua política de sinal.
  - **Comportamento esperado da CPU:**
      - Atualização deslizante do acumulador por iteração.
  - **Critério de Validação:**
      - Vetor [1,2,3,4], W=2 ⇒ out [0,1,2,3].

## Exercício 11
**Função Polinomial por Horner (Calibração de Sensor) com Detecção de Saturação**

**Contexto**

Em sistemas embarcados, muitos sensores **não são lineares**: a leitura bruta (ADC counts) não corresponde diretamente à grandeza física (temperatura, pressão, vazão). Para corrigir isso, a equipe de engenharia geralmente fornece uma **curva de calibração** ajustada em laboratório. Uma forma comum de representar essa curva é um **polinômio**, por exemplo:

`p(x) = a_2*x^2 + a_1*x + a_0`

onde **x** é a leitura bruta (ou uma versão normalizada) e os **coeficientes** `a_0, a_1, a_2` são **constantes** obtidas no ajuste (ex: regressão) e embarcadas no firmware. Avaliar esse polinômio diretamente com potências é caro e aumenta risco de overflow. Por isso usa-se **Horner**, que reescreve o cálculo para minimizar multiplicações e tornar o fluxo mais determinístico:

`p(x) = (a_2*x + a_1) * x + a_0`

Neste exercício, você implementará essa avaliação em **ponto fixo Q16.16**, com **saturação** e **status** quando ocorrer estouro, como ocorre em pipelines críticos de medição.

**Exemplo numérico:**

Curva de calibração (exemplo): `p(x) = 2*x^2 + 3*x + 1`

Coeficientes: `a_2=2`, `a_1=3`, `a_0=1` e leitura `x=4`

**Horner**:

  - passo 1: acc = a2 = 2
  - passo 2: acc = acc * x + a1 = 2 * 4 + 3 = 11
  - passo 3: acc = acc * x + a0 = 11 * 4 + 1 = 45

Logo, `p(4)=45`.

**Tarefa**

Implemente em lib.S a função poly_horner_q16_sat:

  - **Entrada:**
      - x0 = ptr coef (int32 Q16.16), tamanho N
      - Ordem **obrigatória**: coef[0]=`a_(N-1)` (maior grau) ... coef[N-1]=`a_0` (termo constante)
      - x1 = N (>=1)
      - w2 = x (Q16.16)
  - **Saída:**
      - w0 = p(x) (Q16.16)
      - w1 = status (0=OK, 1=ponteiro nulo, 2=N inválido, 3=saturou)

**Regras:**

  - Se ptr==0 ⇒ status 1.
  - Se N==0 ⇒ status 2.
  - Avalie por Horner:
      - acc = coef[0]
      - para i=1..N-1: acc = acc*x + coef[i] (com normalização Q16.16)
  - Aplique saturação no acumulador (Q16.16) em `[-2^31, 2^31-1]` e sinalize status 3 se ocorrer.

**Requisitos Técnicos e Saídas Esperadas**

  - **Especificações de Projeto:**
      - Multiplicação em 64 bits e shift correto para Q16.16.
      - Preserve callee-saved se usados.
  - **Comportamento esperado da CPU:**
      - Laço percorre os coeficientes; branches tratam saturação.
  - **Critério de Validação:**
      - Em main.S, teste um conjunto de coeficientes simples e um x que provoque saturação.
      - Confirme w1 e o valor final em w0.

## Exercício 12
**Mini-Projeto: Pipeline de Diagnóstico de Sensor (IMU) com Fallback e Relatório**

**Contexto**

Em um módulo embarcado de navegação inercial (IMU), o firmware recebe amostras de aceleração e giroscópio, faz pré-processamento e calcula métricas para detectar falhas: saturação, ruído elevado, drift e inconsistências. No Raspberry Pi Zero 2W, você precisa de um pipeline determinístico: (1) normalização de amostras, (2) cálculo de energia (integração/estatística), (3) cálculo de magnitude/ângulo com aproximação numérica, e (4) geração de um código final de diagnóstico para o sistema de bordo. O mini-projeto exige várias funções, todas em lib.S, chamadas por um main.S que prepara dados e valida resultados. Você deverá implementar tratamento de erros (ponteiros nulos, N inválido, dt inválido, divisão por zero), usar loops e pelo menos um switch para classificar o estado final. O objetivo é produzir um **status final** e, opcionalmente, um pequeno buffer de saída com valores intermediários para inspeção em GDB.

**Exemplo de fluxo**

  - amostras saturadas ⇒ flag de erro ≠ 0 ⇒ classificação final FAULT
  - amostras ok, mas magnitude > limiar ⇒ DEGRADED
  - amostras ok e magnitude ≤ limiar ⇒ OK

**Tarefa**

Implemente em lib.S as funções abaixo e integre tudo em main.S:

1.  normalize_saturate_i16_to_i32 (do Exercício 1)
2.  dot_i32_checked (do Exercício 3) para calcular **energia aproximada** (ex: dot do vetor com ele mesmo)
3.  safe_div_s64 (do Exercício 4) para computar **média** (sum / N) com política de erro
4.  sqrt_nr (do Exercício 7) para magnitude (double) **a partir da energia** (converta para double de forma explícita)
5.  classify_health (NOVO) com **switch**:
      - Entrada: w0 = flags de erro (bitmask), d0 = magnitude, d1 = limiar
      - Saída: w0 = código final (0=OK, 1=DEGRADED, 2=FAULT)
      - Regras (implemente exatamente):
          - Se flags != 0 ⇒ FAULT
          - Senão se magnitude > limiar ⇒ DEGRADED
          - Senão ⇒ OK

**Pipeline em main.S:**

  - Inicialize um vetor de amostras int16_t (com casos normais e extremos).
  - Normalize e gere vetor int32_t.
  - Calcule energia com dot product (vetor com ele mesmo).
  - Calcule média com safe_div_s64.
  - Converta para double e calcule magnitude com sqrt_nr.
  - Classifique com classify_health.
  - Retorne ao SO com exit code igual ao código final (syscall exit).

**Requisitos Técnicos e Saídas Esperadas**

  - **Especificações de Projeto:**
      - **ABI obrigatória em todas as funções**, com prólogo/epílogo corretos.
      - Preservação de x19–x28 e v8–v15 quando usados.
      - Stack sempre alinhada.
  - **Comportamento esperado da CPU:**
      - Fluxo principal encadeia chamadas via bl.
      - Erros propagam via bitmask de flags (defina bits: ex: bit0 ponteiro nulo, bit1 N inválido, bit2 dt inválido, bit3 overflow).
      - Switch final define o diagnóstico.
  - **Critério de Validação (GDB + Exit Code):**
      - Confirme em GDB:
          - vetor int32_t normalizado
          - energia (x0) e status (w1) do dot product
          - magnitude em d0 após sqrt_nr
          - código final em w0 após classify_health
      - Execute e verifique o **código de saída** do processo (echo $?) como validação final.

-----

### Formato de entrega

A entrega deste assessment deve seguir rigorosamente os critérios abaixo:

  - Todos os arquivos gerados devem ser organizados e compactados em um único arquivo **.ZIP**.
  - O pacote deve conter **todo o código-fonte desenvolvido**, incluindo main.S, lib.S e quaisquer arquivos auxiliares necessários para compilação e execução.
  - Deve ser incluído um **relatório técnico**, em formato PDF ou Markdown, descrevendo de forma objetiva:
      - a abordagem adotada em cada exercício
      - as decisões de engenharia tomadas
      - como os requisitos técnicos e a ABI foram atendidos
  - Quando solicitado em algum exercício, devem ser incluídas **evidências da execução**, como imagens ou vídeos capturados durante testes e depuração.
  - Deve ser entregue um **vídeo de apresentação** demonstrando o que foi desenvolvido e executado no **Raspberry Pi Zero 2W**, mostrando claramente o fluxo de resolução das questões e a execução dos programas.
  - O vídeo deve ser disponibilizado como **link do YouTube**.
  - O vídeo deve estar com **permissão de visualização ativa** e **não listado** (unlisted).

-----

**Orientações para Defesa do Trabalho em Vídeo**

1.  **Utilize uma ferramenta adequada:** É preciso que apareça a tela com seu trabalho e a imagem da sua webcam. Uma sugestão de ferramenta gratuita online para estudantes é o [Loom](https://www.loom.com/). Caso prefira, existe também a opção de baixar a ferramenta [OBS](https://obsproject.com/pt-br/download), dentre outras.
2.  **Escolha um local adequado:** Grave em um ambiente calmo, sem ruídos ou distrações, para garantir boa qualidade de áudio e foco durante a defesa.
3.  **Webcam ligada:** Certifique-se de que a webcam esteja ativada, com boa iluminação e enquadrando você de forma clara e centralizada.
4.  **Revise o vídeo:** Assista a gravação para verificar se o vídeo e o áudio estão bons.
5.  **Salve o vídeo no Google Drive:** Após a gravação, faça o upload do arquivo para o seu Google Drive de aluno Infnet.
6.  **Altere as permissões de acesso:** Configure o compartilhamento do vídeo para "qualquer pessoa com o link" poder visualizar. Copie o link gerado e envie conforme as instruções da atividade.

-----

Assim que terminar, salve seu trabalho em PDF nomeando o arquivo conforme a regra “**nome_sobrenome_DR2_AT.PDF**” e poste como resposta a este AT.
