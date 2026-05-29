# Roteiro de Video Demonstrativo

Duracao sugerida: 3min30s.

## 00:00-00:20 - Requisitos e estrutura

Fala sugerida:

> Este projeto implementa o AT da DR3 na Tang Nano 9K. O sistema gera 16 amostras internas com sinal, armazena em BRAM, calcula soma, media e RMS simplificado, e transmite os resultados por UART.

Mostrar:

- `Enunciado DR3 AT.html`
- Pastas `src/rtl`, `tb`, `constraints`, `docs`

## 00:20-00:50 - Arquitetura

Fala sugerida:

> A arquitetura usa uma FSM central para coordenar gerador de amostras, BRAM, datapath aritmetico, formatador hexadecimal e transmissor UART. A PLL gera o clock derivado usado pelo sistema.

Mostrar:

- Diagrama Mermaid em `docs/relatorio.md`
- Arquivo `src/rtl/signal_monitor_top.v`

## 00:50-01:30 - FSM e datapath

Fala sugerida:

> A FSM separa a logica de transicao da logica de saida. Durante GENERATE e STORE as amostras sao gravadas na BRAM; em READ e PROCESS elas sao lidas e acumuladas. O datapath calcula a soma, a media por divisao por 16 e o RMS simplificado como media dos quadrados.

Mostrar:

- `src/rtl/signal_monitor_core.v`
- `src/rtl/arithmetic_datapath.v`
- `src/rtl/sample_bram.v`

## 01:30-02:00 - Simulacao

Fala sugerida:

> Os testbenches verificam o fluxo tipico, casos extremos, acesso sincrono a BRAM, UART, PLL simulada e debounce do botao. No fluxo tipico, os resultados sao soma 64, media 4 e RMS simplificado 368.

Mostrar:

- Comando `make sim`
- GTKWave com `gtkwave/dr3_core.gtkw`
- GTKWave com `gtkwave/dr3_uart.gtkw`

## 02:00-02:40 - Hardware na Tang Nano 9K

Fala sugerida:

> Na placa, o START usa um botao onboard, o reset usa o outro botao onboard e os LEDs onboard indicam os estados. Nao foi necessario protoboard porque a saida digital usa o USB-UART onboard.

Mostrar:

- Tang Nano 9K conectada
- Pressionar START
- LEDs durante processamento e no estado DONE

## 02:40-03:10 - Saida UART

Fala sugerida:

> A interface digital transmite a mensagem em 115200 baud, formato 8N1. O terminal mostra as metricas calculadas pelo hardware.

Mostrar:

- Terminal serial com:

```text
DR3_AT N=16 SUM=0x00000040 MEAN=0x00000004 RMS2=0x00000170 DONE
```

## 03:10-03:30 - Fechamento

Fala sugerida:

> Assim, o projeto demonstra a FSM, BRAM, DSP para multiplicacao, PLL, calculo das metricas e comunicacao digital funcionando em simulacao e na Tang Nano 9K.

Mostrar:

- `docs/relatorio.md`
- Evidencias salvas em `evidencias/`

