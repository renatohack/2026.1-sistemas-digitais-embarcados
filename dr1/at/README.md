# Sistema Digital de Controle de Acesso

Entrega desenvolvida ate a etapa de simulacao, sem incluir sintese, mapeamento de pinos ou programacao da FPGA.

## Adaptacao adotada

- Plataforma prevista para continuidade: Tang Nano 9K
- Entradas do codigo: 4 botoes externos no protoboard, equivalentes aos 4 bits que no enunciado original seriam definidos por switches
- Entradas de controle: 1 botao para confirmacao e 1 botao para reset

Para validar um codigo, os botoes correspondentes aos bits em nivel `1` devem permanecer pressionados durante o acionamento do botao de confirmacao.

## Estrutura

- `docs/`: modelagem logica e orientacoes de simulacao
- `gowin/`: arquivos para abrir o projeto da Tang Nano 9K no Gowin
- `rtl/`: modulos em Verilog HDL
- `tb/`: testbench autoavaliavel
- `sim/`: arquivos de waveform e layout do GTKWave

## Como validar

```bash
make sim
```

O comando acima:

1. valida o modulo principal com `tb/access_control_tb.v`
2. valida o wrapper da Tang Nano 9K com `tb/access_control_tang_nano_9k_top_tb.v`
3. gera as waveforms em `sim/vcd/` e `sim/fst/`

Para abrir a simulacao no GTKWave:

```bash
make wave
```

Para abrir a waveform do wrapper da FPGA:

```bash
make wave-board
```

## Projeto para Gowin

Abra o arquivo abaixo diretamente no Gowin IDE:

```bash
gowin/access_control_tang_nano_9k.gprj
```

Os detalhes da pinagem e da montagem dos botoes externos estao em `docs/fpga_tang_nano_9k.md`.
