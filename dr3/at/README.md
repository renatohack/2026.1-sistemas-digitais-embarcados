# DR3 AT - Monitor de Sinal Discreto na Tang Nano 9K

Projeto Verilog para o Assessment Final da DR3. O sistema gera 16 amostras signed, armazena em BRAM, calcula soma, media e RMS simplificado, e transmite os resultados por UART onboard.

## Simulacao

```bash
make sim
```

Abrir GTKWave:

```bash
make wave-core
make wave-uart
```

## Resultado esperado

```text
DR3_AT N=16 SUM=0x00000040 MEAN=0x00000004 RMS2=0x00000170 DONE
```

## Hardware

- Placa: Tang Nano 9K.
- START: botao onboard em `start_n`, pino 3.
- Reset: botao onboard em `rst_n`, pino 4.
- LEDs de estado: LEDs onboard, pinos 10, 11, 13, 14, 15 e 16.
- UART TX: pino 17, via USB-UART onboard.
- Protoboard: nao necessaria na versao padrao.

Constraints:

- `constraints/tangnano9k.cst`
- `constraints/tangnano9k.sdc`

Top level:

- `src/rtl/signal_monitor_top.v`

Projeto Gowin:

- `dr3_at.gprj`

## Documentacao

- Relatorio tecnico: `docs/relatorio.md`
- Guia GTKWave: `docs/guia_gtkwave.md`
- Guia de fotos: `docs/guia_fotos_hardware.md`
- Roteiro do video: `docs/roteiro_video.md`
