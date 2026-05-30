# Guia GTKWave

## Geracao das simulacoes

Execute a partir da raiz do projeto:

```bash
make sim
```

Isso compila e executa todos os testbenches com Icarus Verilog e gera os VCDs em `build/waves/`.

## Antes dos prints

Os comandos abaixo abrem presets separados. Cada preset contem somente os
sinais relevantes para uma evidencia. Nao use `make wave-core` para os prints
do relatorio: esse preset amplo continua disponivel apenas para inspecao livre.

Os tempos indicados abaixo sao os valores exibidos na regua horizontal do
GTKWave. Nao precisam ficar exatos ao nanossegundo: ajuste o zoom ate que a
regua mostre aproximadamente o intervalo solicitado.

## Como colocar o intervalo de tempo no GTKWave

Na barra superior do GTKWave existem campos `From` e `To`. Eles controlam o
trecho navegavel da simulacao e aceitam unidades como `ns` e `us`.

Para cada print:

1. Digite o inicio indicado no campo `From`, por exemplo `0 ns`.
2. Digite o fim indicado no campo `To`, por exemplo `800 ns`.
3. Pressione Enter.
4. Clique no botao `Zoom Fit`, representado por uma lupa ou um quadrado de
   ajuste, para preencher a area de ondas com esse intervalo.

Se a sua versao do GTKWave nao mostrar os campos `From` e `To`:

1. Clique com o botao do meio do mouse sobre o instante inicial para fixar o
   marcador de base.
2. Clique com o botao esquerdo sobre o instante final para posicionar o
   marcador principal.
3. Clique em `Zoom Fit`.

Para medir um pulso ou confirmar uma transicao, clique com o botao esquerdo
sobre a borda do sinal. O tempo do marcador aparece na barra superior.

Legenda dos valores numericos de `state`:

| Valor | Estado |
| ---: | --- |
| `0` | `INIT` |
| `1` | `IDLE` |
| `2` | `GENERATE` |
| `3` | `STORE` |
| `4` | `READ` |
| `5` | `PROCESS` |
| `6` | `FORMAT` |
| `7` | `TX` |
| `8` | `DONE` |
| `9` | `ERROR` |

## Print 01 - FSM: inicio ate transmissao

Abra:

```bash
make wave-fsm
```

Intervalo aproximado:

```text
0 ns ate 800 ns
```

Salve:

```text
evidencias/sim/01_fsm_fluxo_tipico.png
```

Deixe visiveis somente os sinais que o preset abriu:

- `rst_n`
- `start`
- `state`
- `next_state`
- `led`
- `done`

O que deve aparecer:

- `rst_n` muda de `0` para `1` em aproximadamente `45 ns`.
- `state` muda de `INIT (0)` para `IDLE (1)` em aproximadamente `45 ns`.
- `start` gera um pulso de `95 ns` ate `105 ns`.
- `state` alterna entre `GENERATE (2)` e `STORE (3)` de `105 ns` ate `425 ns`.
- `state` alterna entre `READ (4)` e `PROCESS (5)` de `425 ns` ate `745 ns`.
- `state` passa por `FORMAT (6)` entre `745 ns` e `755 ns`.
- `state` entra em `TX (7)` em aproximadamente `755 ns`.
- `done` permanece `0`, porque a UART ainda esta transmitindo.

## Print 01b - FSM: fim da transmissao

Use a mesma janela aberta por:

```bash
make wave-fsm
```

Intervalo aproximado:

```text
65.35 us ate 65.45 us
```

Salve:

```text
evidencias/sim/01b_fsm_estado_done.png
```

O que deve aparecer:

- `state` esta em `TX (7)` no inicio do intervalo.
- `next_state` muda de `TX (7)` para `DONE (8)` em aproximadamente `65.415 us`.
- `state` muda de `TX (7)` para `DONE (8)` em aproximadamente `65.425 us`.
- `done` muda de `0` para `1` junto com a entrada em `DONE`.
- `led` muda porque o LED associado ao estado final passa a ser ativado.

Este segundo print existe porque colocar os `65 us` completos em uma unica
imagem comprime demais as etapas iniciais da FSM.

## Print 02 - Escrita e leitura da BRAM

Abra:

```bash
make wave-bram
```

Intervalo aproximado:

```text
100 ns ate 750 ns
```

Salve:

```text
evidencias/sim/02_bram_escrita_leitura.png
```

Sinais visiveis:

- `clk`
- `state`
- `sample_index`
- `process_index`
- `bram_we`
- `bram_addr`
- `bram_din`
- `bram_dout`

O que deve aparecer:

- De `115 ns` ate `425 ns`, `state` alterna entre `GENERATE (2)` e `STORE (3)`.
- `bram_we` sobe para `1` somente durante cada ciclo `STORE (3)`.
- Durante a escrita, `bram_addr` progride de `0` ate `15`.
- Durante a escrita, `bram_din` percorre as amostras do sensor, iniciando em
  `-28`, `-20`, `-12`, `-4`, `4` e terminando em `-20`.
- A partir de `425 ns`, `bram_we` permanece em `0`.
- De `425 ns` ate `745 ns`, `state` alterna entre `READ (4)` e `PROCESS (5)`.
- Durante a leitura, `process_index` e `bram_addr` progridem de `0` ate `15`.
- `bram_dout` apresenta as amostras previamente armazenadas. A leitura e
  sincrona: o valor de saida aparece apos a aplicacao do endereco no clock.

## Print 03 - Calculo das metricas

Abra:

```bash
make wave-metrics
```

Intervalo aproximado:

```text
420 ns ate 770 ns
```

Salve:

```text
evidencias/sim/03_metricas_datapath.png
```

Sinais visiveis:

- `state`
- `process_index`
- `bram_dout`
- `sum_acc`
- `sumsq_acc`
- `sum_out`
- `mean_out`
- `rms2_out`
- `overflow`

O que deve aparecer:

- `process_index` progride de `0` ate `15`.
- `sum_acc` e `sumsq_acc` mudam a cada amostra processada.
- Em aproximadamente `745 ns`, os acumuladores terminam em:
  - `sum_acc = 64`
  - `sumsq_acc = 5888`
- Em aproximadamente `755 ns`, depois do estado `FORMAT (6)`, aparecem:
  - `sum_out = 64`
  - `mean_out = 4`
  - `rms2_out = 368`
- `overflow` permanece em `0`.

## Print 04 - UART em simulacao

Abra:

```bash
make wave-uart
```

Intervalo aproximado:

```text
750 ns ate 4.90 us
```

Salve:

```text
evidencias/sim/04_uart_transmissao.png
```

Sinais principais:

- `state`
- `tx_data_latch`
- `bit_cnt`
- `tx_valid`
- `tx_ready`
- `uart_tx`

O que deve aparecer:

- `state` permanece em `TX (7)`.
- `tx_valid` sobe para `1` em aproximadamente `765 ns`.
- `tx_data_latch` mostra os primeiros caracteres ASCII:

| Tempo aproximado | Hexadecimal | Caractere |
| ---: | ---: | --- |
| `775 ns` | `0x44` | `D` |
| `1.785 us` | `0x52` | `R` |
| `2.795 us` | `0x33` | `3` |
| `3.805 us` | `0x5F` | `_` |
| `4.815 us` | `0x41` | `A` |

- `uart_tx` fica em `1` quando o transmissor esta ocioso.
- Para cada caractere, `uart_tx` cai para `0` no start bit e depois varia
  conforme os 8 bits de dados antes de retornar ao stop bit em `1`.
- `bit_cnt` progride pelos bits do caractere.
- `tx_ready` pulsa entre os caracteres.

O teste completo decodifica automaticamente toda a mensagem:

```text
DR3_AT N=16 SUM=0x00000040 MEAN=0x00000004 RMS2=0x00000170 DONE
```

## Print 05 - PLL e clock derivado

Abra:

```bash
make wave-pll
```

Intervalo aproximado:

```text
0 ns ate 250 ns
```

Salve:

```text
evidencias/sim/05_pll_clock_derivado.png
```

Sinais visiveis:

- `clk_27`
- `reset`
- `pll_locked`
- `clk_proc`

O que deve aparecer:

- `reset` inicia em `1` e cai para `0` em aproximadamente `60 ns`.
- `pll_locked` inicia em `0` e sobe para `1` em aproximadamente `120 ns`.
- `clk_27` tem periodo aproximado de `37 ns`, representando `27 MHz`.
- `clk_proc` tem periodo aproximado de `18 ns`, representando cerca de `54 MHz`.
- Portanto, o clock derivado tem aproximadamente o dobro da frequencia do
  clock de entrada.

## Resumo dos arquivos

| Comando | Evidencia |
| --- | --- |
| `make wave-fsm` | `01_fsm_fluxo_tipico.png` e `01b_fsm_estado_done.png` |
| `make wave-bram` | `02_bram_escrita_leitura.png` |
| `make wave-metrics` | `03_metricas_datapath.png` |
| `make wave-uart` | `04_uart_transmissao.png` |
| `make wave-pll` | `05_pll_clock_derivado.png` |
