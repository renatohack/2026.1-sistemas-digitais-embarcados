# Relatório Técnico - DR4 AT

Versão auxiliar em Markdown. A versão final diagramada está em
`relatorio_DR4_AT.html` e `relatorio_DR4_AT.pdf`.

## Resumo

O Assessment Final foi implementado como um executável stand-alone em Assembly ARM64,
sem libc, com dados internos de telemetria e relatório compacto em stdout. O sistema
calcula métricas escalares, manipula campos de bits, usa LUT, executa rotinas SIMD
NEON inteiras e de ponto flutuante, utiliza macros GAS para syscalls e valida a saída
por QEMU.

## Resultado funcional

- Amostras válidas: `7`
- Soma dos valores válidos: `290`
- Média inteira: `41`
- Alarmes ativos: `1`
- Bateria baixa: `1`
- Palavra de status: `0x1117`
- Rotação manual: `0x22e2`
- Assinatura por EOR: `0x33f5`
- LUT dos válidos: `100 200 300 400 500 600 800`
- Soma LUT: `2900`
- Soma NEON dos quatro primeiros valores: `100`
- Normalização float32 SIMD: `0.100 0.200 0.300 0.400`

## Evidências

- `../evidencias/qemu_output.txt`
- `../evidencias/gdb_registers.txt`
- `../evidencias/objdump_full.txt`
- `../evidencias/objdump_processamento.txt`
- `../evidencias/readelf_sections_symbols.txt`
- `../evidencias/binario_info.txt`
