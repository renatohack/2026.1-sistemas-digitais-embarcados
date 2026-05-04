# Guia manual TP2

Este guia cobre apenas as etapas que dependem do ambiente Gowin/Tang Nano 9K e das evidencias fisicas.

## 1. Sintese e programacao no Gowin

1. Abra `tp2/gowin/tp2_sequence_validator.gprj` no Gowin IDE.
2. Confirme que o device esta como `GW1NR-LV9QN88PC6/I5`.
3. Rode:
   - `Synthesize`
   - `Place & Route`
   - `Program Device`
4. Programe em `SRAM` para teste rapido. Use `FLASH` apenas se quiser persistencia.

## 2. Confirmacao de uso de PLL, BRAM e DSP

Nao precisa ficar tirando print caçando isso manualmente no Gowin.

Use os arquivos:

- `gowin/impl/pnr/tp2_sequence_validator.rpt.txt`
- `gowin/impl/gwsynthesis/tp2_sequence_validator_syn_resource.html`
- `evidencias/recursos_fpga_tp2.txt`
- `evidencias/hierarquia_recursos_tp2.txt`

Os dois arquivos em `evidencias/` ja deixam extraidos os trechos relevantes:

- `BSRAM | 1/26 | 4%`
- `DSP | 1/10 | 10%`
- `MULTADDALU18X18 | 1`
- `rPLL | 1/2 | 50%`
- hierarquia com:
  - `pll_wrapper_inst`
  - `sync_bram_inst`
  - `dsp_mac_inst`

Se o Gowin nao inferir BRAM ou DSP como esperado:

1. mantenha os relatorios gerados no ZIP;
2. me avise qual recurso nao foi inferido;
3. eu ajusto o modulo correspondente para forcar primitive/IP Gowin sem alterar a interface externa.

## 3. Checklist de funcionamento em hardware

Com a mesma montagem do TP1:

1. Pressione `reset` na Tang.
2. Verifique se os LEDs onboard mostram a sequencia:
   - LED0
   - LED2
   - LED1
   - LED3
3. Ao terminar a exibicao, o display deve mostrar o progresso da entrada:
   - `0` antes do primeiro botao
   - `1` depois do primeiro acerto
   - `2` depois do segundo acerto
   - `3` depois do terceiro acerto
4. Na sequencia correta `0,2,1,3`, o display deve ciclar:
   - `S`
   - `2`
   - `9`
5. Em caso de erro, o display deve mostrar `E`.

## 4. Evidencias visuais para gerar manualmente

Capture pelo menos:

1. tela do Gowin com sintese/PNR concluido;
2. o video mostrando o fluxo fisico completo;
3. screenshots das waveforms de simulacao.

## 5. Video curto

Grave um video curto mostrando:

1. reset da placa;
2. sequencia automatica nos LEDs;
3. digitacao correta `0,2,1,3`;
4. display ciclando `S`, `2`, `9`;
5. novo reset;
6. digitacao errada;
7. display mostrando `E`.

## 6. Evidencias de simulacao

Os testbenches geram VCDs. Rode os comandos abaixo a partir da pasta `tp2/`.

### 6.1 BRAM

```bash
mkdir -p sim/build
iverilog -g2005 -o sim/build/tb_sync_bram.vvp \
  gowin/src/sync_bram.v \
  sim/tb_sync_bram.v
vvp sim/build/tb_sync_bram.vvp
gtkwave sim/build/tb_sync_bram.vcd
```

Sinais para incluir na tela:

- `tb_sync_bram.clk`
- `tb_sync_bram.en`
- `tb_sync_bram.we`
- `tb_sync_bram.addr[3:0]`
- `tb_sync_bram.din[15:0]`
- `tb_sync_bram.dout[15:0]`

O print deve mostrar pelo menos:

- escrita em `addr 0` e `addr 1`;
- leitura sincronizada desses enderecos;
- leitura do checksum em `addr 8`.

### 6.2 DSP

```bash
mkdir -p sim/build
iverilog -g2005 -o sim/build/tb_dsp_mac.vvp \
  gowin/src/dsp_mac.v \
  sim/tb_dsp_mac.v
vvp sim/build/tb_dsp_mac.vvp
gtkwave sim/build/tb_dsp_mac.vcd
```

Sinais para incluir na tela:

- `tb_dsp_mac.clk`
- `tb_dsp_mac.rst_n`
- `tb_dsp_mac.clear`
- `tb_dsp_mac.valid`
- `tb_dsp_mac.a[15:0]`
- `tb_dsp_mac.b[15:0]`
- `tb_dsp_mac.acc[31:0]`

O print deve mostrar:

- `clear` zerando o acumulador;
- quatro MACs consecutivos;
- `acc` chegando em `29`.

### 6.3 Integracao completa

```bash
mkdir -p sim/build
iverilog -g2005 -o sim/build/tb_tp2_sequence_validator.vvp \
  gowin/src/button_conditioner.v \
  gowin/src/dsp_mac.v \
  gowin/src/gowin_rpll_27_to_13p5.v \
  gowin/src/pll_wrapper.v \
  gowin/src/result_display_mux.v \
  gowin/src/seven_segment_decoder.v \
  gowin/src/sequence_fsm.v \
  gowin/src/sequence_validator_top.v \
  gowin/src/sync_bram.v \
  sim/tb_tp2_sequence_validator.v
vvp sim/build/tb_tp2_sequence_validator.vvp
gtkwave sim/build/tb_tp2_sequence_validator.vcd
```

Sinais para incluir na tela:

- `tb_tp2_sequence_validator.sys_clk`
- `tb_tp2_sequence_validator.sys_rst_n`
- `tb_tp2_sequence_validator.dut.core_clk`
- `tb_tp2_sequence_validator.dut.pll_lock`
- `tb_tp2_sequence_validator.btn_n[3:0]`
- `tb_tp2_sequence_validator.led_n[3:0]`
- `tb_tp2_sequence_validator.dut.state_debug[3:0]`
- `tb_tp2_sequence_validator.dut.step_debug[1:0]`
- `tb_tp2_sequence_validator.dut.bram_en`
- `tb_tp2_sequence_validator.dut.bram_we`
- `tb_tp2_sequence_validator.dut.bram_addr[3:0]`
- `tb_tp2_sequence_validator.dut.bram_din[15:0]`
- `tb_tp2_sequence_validator.dut.bram_dout[15:0]`
- `tb_tp2_sequence_validator.dut.dsp_clear`
- `tb_tp2_sequence_validator.dut.dsp_valid`
- `tb_tp2_sequence_validator.dut.dsp_a[15:0]`
- `tb_tp2_sequence_validator.dut.dsp_b[15:0]`
- `tb_tp2_sequence_validator.dut.dsp_acc[31:0]`
- `tb_tp2_sequence_validator.dut.checksum_debug[7:0]`
- `tb_tp2_sequence_validator.dut.success_phase_debug[1:0]`
- `tb_tp2_sequence_validator.seg_a`
- `tb_tp2_sequence_validator.seg_b`
- `tb_tp2_sequence_validator.seg_c`
- `tb_tp2_sequence_validator.seg_d`
- `tb_tp2_sequence_validator.seg_e`
- `tb_tp2_sequence_validator.seg_f`
- `tb_tp2_sequence_validator.seg_g`

O ideal e tirar dois prints dessa simulacao:

1. um print mostrando:
   - `pll_lock`
   - inicializacao da BRAM
   - sequencia nos LEDs
   - gravacao das entradas do usuario

2. outro print mostrando:
   - fase DSP com `dsp_valid`, `dsp_a`, `dsp_b`, `dsp_acc`
   - escrita do checksum em `addr 8`
   - chegada em `29`
   - fase de sucesso
