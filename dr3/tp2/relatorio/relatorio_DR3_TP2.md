# Relatório Técnico - DR3 TP2

Este arquivo é uma versão auxiliar em Markdown. A versão final diagramada está em
`relatorio_DR3_TP2.html` e `relatorio_DR3_TP2.pdf`.

## Resumo

O TP2 evolui o validador de sequência do TP1 mantendo a mesma montagem física na Tang
Nano 9K. A FSM continua sendo o núcleo de controle, mas passa a orquestrar BRAM
síncrona, DSP MAC e PLL.

## Recursos usados

- BRAM: `sync_bram`, com mapa de memória para sequência esperada, entradas e checksum.
- DSP: `dsp_mac`, calculando `sum((entrada[i] + 1) * (i + 1))`.
- PLL: `pll_wrapper`, gerando clock interno derivado.

## Resultado

Para a sequência correta `0,2,1,3`, o checksum é `29`. No sucesso, o display cicla
`S -> 2 -> 9`. No erro, o display mostra `E`.

## Evidências

- `evidencias/synth_pnr_ok.png`
- `evidencias/recursos_fpga_tp2.txt`
- `evidencias/hierarquia_recursos_tp2.txt`
- `evidencias/tb_sync_bram.png`
- `evidencias/tb_dsp_mac.png`
- `evidencias/tb_tp2_sequence_validator_1.png`
- `evidencias/tb_tp2_sequence_validator_2.png`
- `evidencias/link_video.txt`
