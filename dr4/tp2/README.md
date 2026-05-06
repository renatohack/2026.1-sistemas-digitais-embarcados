# TP2 - DR4 - Assembly ARM64

Implementacao dos 12 exercicios do TP2 da disciplina DR4, com rotinas em Assembly ARM64
e validacao automatizada por binario AArch64 executado em `qemu-aarch64`.

## Estrutura

- `src/tp2_exercises.S`: implementacao das 12 rotinas e das lookup tables.
- `include/tp2.h`: assinaturas usadas pelo harness.
- `tests/test_tp2.c`: suite de testes automatizados.
- `evidencias/qemu_test_output.txt`: log completo da validacao.
- `relatorios/relatorio_DR4_TP2.html`: relatorio tecnico final diagramado.
- `relatorios/relatorio_DR4_TP2.pdf`: exportacao em PDF do relatorio.
- `relatorios/template_relatorio_DR4_TP2.html`: template reutilizavel no mesmo visual.

## Comandos

```bash
make
make test
make evidence
```

## Observacoes

- O binario gerado e um ELF AArch64 estatico, apropriado para Linux ARM64.
- A validacao foi feita em `qemu-aarch64`, conforme autorizacao do professor.
- O video nao foi produzido porque foi dispensado.
