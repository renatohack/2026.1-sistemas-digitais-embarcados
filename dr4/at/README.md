# DR4 AT - Diagnóstico de Telemetria em Assembly ARM64

Trabalho final da disciplina DR4 implementado como executável stand-alone em
Assembly ARM64, sem libc, com syscalls Linux diretas. A validação local usa
`qemu-aarch64`, conforme autorização do professor.

## Estrutura

- `src/main.s`: ponto de entrada `_start`, integração do fluxo e emissão do relatório em stdout.
- `src/processamento.s`: métricas escalares, manipulação de bits, LUT e rotinas NEON.
- `src/conversao.s`: conversão inteiro-string, hexadecimal fixo, `strlen` e parser validado.
- `src/macros.inc`: macros GAS para `write`, `exit` e carregamento PC-relative.
- `tests/expected_output.txt`: saída esperada do executável para validação por `diff`.
- `scripts/capture_gdb.sh`: captura de registradores via `gdb-multiarch` conectado ao QEMU.
- `evidencias/`: logs de execução, objdump, readelf, GDB e metadados do binário.
- `relatorios/`: relatório técnico final em HTML/PDF.

## Comandos

```bash
make
make test
make evidence
make gdb-evidence
make report
make clean
```

## Resultados esperados

- Amostras válidas: `7`
- Soma dos válidos: `290`
- Média inteira: `41`
- Alarmes ativos: `1`
- Bateria baixa: `1`
- LUT dos válidos: `100 200 300 400 500 600 800`
- Soma NEON dos quatro primeiros valores: `100`
- Normalização SIMD float32: `0.100 0.200 0.300 0.400`
