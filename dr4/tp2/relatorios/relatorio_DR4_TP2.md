# Relatório Técnico - DR4 TP2

Este arquivo é uma versão auxiliar em Markdown. A versão final diagramada está em
`relatorio_DR4_TP2.html` e `relatorio_DR4_TP2.pdf`.

## Resumo

O trabalho implementa 12 exercícios em Assembly ARM64 cobrindo lookup tables, mascaramento
de bits, extração e inserção de campos, rotação manual e um pipeline completo de
extração -> lookup -> ajuste final.

## Ambiente

- Cross-compiler: `aarch64-linux-gnu-gcc`
- Execução: `qemu-aarch64`
- Alvo previsto: Raspberry Pi Zero 2W / Linux AArch64
- Binário gerado: ELF 64-bit estático para ARM aarch64

## Resultado

Todos os 12 exercícios passaram na suíte de validação automatizada. O log completo está em
`../evidencias/qemu_test_output.txt`.

## Evidências

- `../evidencias/qemu_test_output.txt`
- `../evidencias/binario_info.txt`
- `../README.md`
