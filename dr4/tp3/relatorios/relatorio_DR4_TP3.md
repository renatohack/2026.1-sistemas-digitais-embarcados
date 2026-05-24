# Relatório Técnico - DR4 TP3

Este arquivo é uma versão auxiliar em Markdown. A versão final diagramada está em
`relatorio_DR4_TP3.html` e `relatorio_DR4_TP3.pdf`.

## Resumo

O trabalho implementa 12 exercícios em Assembly ARM64 com NEON SIMD e macros GAS,
cobrindo inserção de registradores gerais em lanes vetoriais, inicialização de
vetores, shuffle por `TBL`, shifts por lane, soma vetorial inteira, dot product,
soma float32 e geração de blocos repetitivos por macro parametrizada.

## Ambiente

- Cross-compiler: `aarch64-linux-gnu-gcc`
- Execução: `qemu-aarch64`
- Evidência de registradores: `gdb-multiarch` conectado ao QEMU
- Desassemblagem: `aarch64-linux-gnu-objdump`
- Alvo previsto: Raspberry Pi Zero 2W / Linux AArch64
- Binário gerado: ELF 64-bit estático para ARM aarch64

## Resultado

Todos os 12 exercícios passaram na suíte de validação automatizada. O log completo
está em `../evidencias/qemu_test_output.txt`.

## Evidências

- `../evidencias/qemu_test_output.txt`
- `../evidencias/binario_info.txt`
- `../evidencias/objdump_tp3_exercises.txt`
- `../evidencias/gdb_registers.txt`
- `../README.md`
