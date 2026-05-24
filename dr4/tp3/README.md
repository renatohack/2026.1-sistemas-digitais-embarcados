# TP3 - DR4 - NEON SIMD e macros GAS

Implementacao dos 12 exercicios do TP3 da disciplina DR4, com rotinas em
Assembly ARM64 usando NEON SIMD e macros do GAS. A validacao automatizada gera um
binario AArch64 estatico e o executa com `qemu-aarch64`.

## Estrutura

- `src/tp3_exercises.S`: implementacao das 12 rotinas, macros e constante de shuffle.
- `include/tp3.h`: assinaturas usadas pelo harness.
- `tests/test_tp3.c`: suite de testes automatizados.
- `evidencias/qemu_test_output.txt`: log completo da validacao.
- `evidencias/objdump_tp3_exercises.txt`: evidencia de expansao das macros.
- `evidencias/binario_info.txt`: metadados do executavel gerado.
- `relatorios/relatorio_DR4_TP3.html`: relatorio tecnico final diagramado.
- `relatorios/relatorio_DR4_TP3.pdf`: exportacao em PDF do relatorio.

## Comandos

```bash
make
make test
make evidence
make gdb-evidence
make report
```

## Observacoes

- O binario gerado e um ELF AArch64 estatico, apropriado para Linux ARM64.
- A validacao foi feita em `qemu-aarch64`, conforme autorizacao do professor.
- As evidencias textuais cobrem execucao, formato do binario e desassemblagem.
