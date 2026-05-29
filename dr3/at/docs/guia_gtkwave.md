# Guia GTKWave

## Geracao das simulacoes

Execute a partir da raiz do projeto:

```bash
make sim
```

Isso compila e executa todos os testbenches com Icarus Verilog e gera os VCDs em `build/waves/`.

## Abrir os presets

Fluxo principal da FSM, BRAM e datapath:

```bash
make wave-core
```

UART serial com a mensagem de resultados:

```bash
make wave-uart
```

Se preferir abrir manualmente:

```bash
gtkwave gtkwave/dr3_core.gtkw
gtkwave gtkwave/dr3_uart.gtkw
```

## Prints esperados para o relatorio

Salve as capturas com estes nomes:

- `evidencias/sim/01_fsm_fluxo_tipico.png`
- `evidencias/sim/02_bram_escrita_leitura.png`
- `evidencias/sim/03_metricas_datapath.png`
- `evidencias/sim/04_uart_transmissao.png`

## Sinais que devem aparecer

No preset `dr3_core.gtkw`:

- Clock/reset/start: `clk`, `rst_n`, `start`
- FSM: `state`, `next_state`
- Indices: `sample_index`, `process_index`
- BRAM: `bram_we`, `bram_addr`, `bram_din`, `bram_dout`
- Sensor: `sample_value`
- Datapath: `sum_acc`, `sumsq_acc`, `sum_out`, `mean_out`, `rms2_out`, `overflow`
- Saida: `tx_byte`, `tx_valid`, `tx_ready`, `uart_tx`, `led`, `done`

No preset `dr3_uart.gtkw`:

- `uart_tx`, `tx_valid`, `tx_ready`, `tx_byte`
- `sum_out`, `mean_out`, `rms2_out`
- `state`, `done`

## Como interpretar os prints

- `01_fsm_fluxo_tipico.png`: mostre a sequencia `INIT -> IDLE -> GENERATE -> STORE -> READ -> PROCESS -> FORMAT -> TX -> DONE`.
- `02_bram_escrita_leitura.png`: destaque `bram_we` ativo durante `STORE`, endereco de 0 a 15 e depois leituras sincronas em `READ`.
- `03_metricas_datapath.png`: mostre os acumuladores terminando com `sum_out=64`, `mean_out=4` e `rms2_out=368`.
- `04_uart_transmissao.png`: mostre `tx_byte` avancando pelos caracteres da mensagem e `uart_tx` alternando em 8N1.

