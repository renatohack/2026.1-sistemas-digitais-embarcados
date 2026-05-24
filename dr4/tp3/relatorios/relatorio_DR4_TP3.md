# Relatorio Tecnico - DR4 TP3

Este arquivo e uma versao auxiliar em Markdown. A versao final diagramada esta em
`relatorio_DR4_TP3.html` e `relatorio_DR4_TP3.pdf`.

## Resumo

O trabalho implementa 12 exercicios em Assembly ARM64 com NEON SIMD e macros GAS,
cobrindo insercao de registradores gerais em lanes vetoriais, inicializacao de
vetores, shuffle por `TBL`, shifts por lane, soma vetorial inteira, dot product,
soma float32 e geracao de blocos repetitivos por macro parametrizada.

## Ambiente

- Cross-compiler: `aarch64-linux-gnu-gcc`
- Execucao: `qemu-aarch64`
- Evidencia de registradores: `gdb-multiarch` conectado ao QEMU
- Desassemblagem: `aarch64-linux-gnu-objdump`
- Alvo previsto: Raspberry Pi Zero 2W / Linux AArch64
- Binario gerado: ELF 64-bit estatico para ARM aarch64

## Resultado

Todos os 12 exercicios passaram na suite de validacao automatizada. O log completo
esta em `../evidencias/qemu_test_output.txt`.

## Evidencias

- `../evidencias/qemu_test_output.txt`
- `../evidencias/binario_info.txt`
- `../evidencias/objdump_tp3_exercises.txt`
- `../evidencias/gdb_registers.txt`
- `../README.md`
