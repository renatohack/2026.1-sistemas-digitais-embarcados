# Checklist Final de Entrega

Use esta lista na ordem indicada.

## 1. Simulacao no WSL

- [ ] Executar `make sim`.
- [ ] Conferir que os 6 testbenches terminam com `PASS`.
- [ ] Executar `make wave-fsm` e salvar:
  - `evidencias/sim/01_fsm_fluxo_tipico.png`
- [ ] Na mesma janela de `make wave-fsm`, aproximar o final da transmissao e salvar:
  - `evidencias/sim/01b_fsm_estado_done.png`
- [ ] Executar `make wave-bram` e salvar:
  - `evidencias/sim/02_bram_escrita_leitura.png`
- [ ] Executar `make wave-metrics` e salvar:
  - `evidencias/sim/03_metricas_datapath.png`
- [ ] Executar `make wave-uart` e salvar:
  - `evidencias/sim/04_uart_transmissao.png`
- [ ] Executar `make wave-pll` e salvar:
  - `evidencias/sim/05_pll_clock_derivado.png`

## 2. Sintese e programacao no Windows

- [ ] Abrir `dr3_at.gprj` no Gowin EDA.
- [ ] Confirmar top level `signal_monitor_top`.
- [ ] Confirmar device `GW1NR-LV9QN88PC6/I5`.
- [ ] Confirmar CST e SDC habilitados.
- [ ] Rodar sintese e place/route sem erros.
- [ ] Conferir no relatorio de utilizacao uso de BRAM/BSRAM, DSP ou multiplicador e PLL.
- [ ] Abrir `impl/pnr/dr3_at.rpt.txt` e salvar o print de BSRAM/DSP:
  - `evidencias/hardware/01_relatorio_utilizacao_gowin.png`
- [ ] No mesmo arquivo, salvar o print de `rPLL`:
  - `evidencias/hardware/01b_relatorio_pll.png`
- [ ] Gerar bitstream e programar a Tang Nano 9K.

## 3. Validacao fisica e UART no Windows

- [ ] Tirar foto da placa conectada:
  - `evidencias/hardware/02_placa_conectada_idle.jpeg`
- [ ] Tirar foto dos LEDs em DONE:
  - `evidencias/hardware/03_estado_done_leds.jpeg`
- [ ] Encontrar a porta COM com:

```powershell
Get-CimInstance Win32_SerialPort | Select-Object DeviceID, Description
```

- [ ] Abrir terminal serial Windows em `115200 8N1`, sem controle de fluxo.
- [ ] Pressionar START e conferir:

```text
DR3_AT N=16 SUM=0x00000040 MEAN=0x00000004 RMS2=0x00000170 DONE
```

- [ ] Salvar print:
  - `evidencias/hardware/04_terminal_uart_resultados.png`

## 4. Relatorio

- [ ] Conferir se todas as imagens acima aparecem corretamente em `docs/relatorio.md`.
- [ ] Renderizar os diagramas Mermaid no processo de exportacao.
- [ ] Revisar identificacao do aluno, disciplina e data na capa a ser adicionada.
- [ ] Exportar o relatorio final para PDF.

## 5. Video

- [ ] Gravar seguindo `docs/roteiro_video.md`.
- [ ] Mostrar execucao na placa, FSM, metricas e UART.
- [ ] Conferir audio, legibilidade dos terminais e duracao.

## 6. Pacote final

- [ ] Incluir codigo Verilog, top level, testbenches, constraints e `dr3_at.gprj`.
- [ ] Incluir relatorio PDF com evidencias.
- [ ] Incluir ou enviar o video conforme a plataforma da disciplina.
- [ ] Abrir o pacote final em uma pasta separada e conferir se os arquivos essenciais estao presentes.
