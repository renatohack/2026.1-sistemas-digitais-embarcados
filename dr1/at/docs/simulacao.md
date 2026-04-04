# Simulacao e Validacao

## Organizacao da implementacao

- `rtl/code_validator.v`: logica combinacional de verificacao do codigo `1011`
- `rtl/access_control.v`: sincronizacao dos botoes, contador sincrono de 3 bits e registro das saidas
- `tb/access_control_tb.v`: testbench autoavaliavel
- `gowin/src/access_control_tang_nano_9k_top.v`: wrapper da FPGA com debounce e toggle para os 4 botoes do codigo

## Cenarios cobertos no testbench

1. `reset_inicial`: limpa contador e LEDs de status
2. `codigo_correto`: valida `1011` e acende `LED0`
3. `codigo_incorreto`: valida um codigo invalido e acende `LED1`
4. `multiplas_1` e `multiplas_2`: verificam incremento do contador em tentativas sucessivas
5. `reset_final`: volta o sistema ao estado inicial

No testbench da placa (`tb/access_control_tang_nano_9k_top_tb.v`), os botoes do codigo sao pressionados como pulsos momentaneos e o estado armazenado dos bits e validado como toggle.

O testbench tambem verifica que:

- `LED2` responde durante o acionamento de `BTN_CONFIRM`
- o contador e incrementado apenas uma vez por pressionamento, mesmo com o botao mantido pressionado por varios ciclos
- `LED0` e `LED1` refletem o resultado da ultima tentativa
- o contador exibido em `led_count[2:0]` e binario, conforme o enunciado:
  - 1 tentativa = `001`
  - 2 tentativas = `010`
  - 3 tentativas = `011`
  - 4 tentativas = `100`

## Arquivos de waveform

Depois de executar `make sim`, ficam disponiveis:

- `sim/vcd/access_control.vcd`
- `sim/fst/access_control.fst`
- `sim/gtkwave/access_control.gtkw`

## Abrindo no GTKWave

```bash
make wave
```

Ou diretamente:

```bash
gtkwave sim/fst/access_control.fst sim/gtkwave/access_control.gtkw
```

## Sinais principais para analise

As formas de onda foram organizadas para evidenciar:

- verificacao do codigo: `tb_access_control.dut.code_sync[3:0]` e `tb_access_control.dut.code_valid`
- funcionamento do contador: `tb_access_control.led_count[2:0]`
- comportamento das saidas: `tb_access_control.led_authorized`, `tb_access_control.led_denied` e `tb_access_control.led_attempt`

## Observacao sobre o GTKWave

O GTKWave nao gera estimulos novos por conta propria.

Ele apenas visualiza os sinais que foram gravados na simulacao.

Entao os cenarios de:

- codigo correto
- codigo incorreto
- multiplas tentativas
- reset

ja estao prontos dentro da waveform gerada pelo testbench.
