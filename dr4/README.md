# TP1 - Assembly ARM64 no Raspberry Pi Zero 2W

Projeto do TP1 da disciplina de Processamento Otimizado em Assembly ARM 64-bits, estruturado para:

- compilar nativamente no Raspberry Pi Zero 2W com `make`;
- compilar em host `x86_64` com `aarch64-linux-gnu-*`;
- validar localmente via `qemu-aarch64`;
- gerar evidencias em caminhos previsiveis para o relatorio.

## Estrutura

- `src/asm/`: rotinas Assembly cobradas no TP.
- `src/c/`: harnesses de teste e driver final.
- `include/`: contratos e codigos de status.
- `scripts/`: automacao de execucao, GDB e captura de evidencias.
- `docs/reference/`: material tecnico auxiliar.
- `docs/report/`: relatorio tecnico em andamento.
- `evidence/qemu/`: evidencias geradas na validacao local.
- `evidence/raspberry/`: caminhos esperados para as evidencias finais no Raspberry.

## Comandos principais

```bash
make
make test
make run
```

## Captura automatizada de evidencias

No host com QEMU:

```bash
./scripts/qemu/capture_qemu_evidence.sh
```

No Raspberry Pi:

```bash
./scripts/raspberry/capture_raspberry_evidence.sh
```

## Binarios gerados

- `build/bin/ex2_soc_addrs`
- `build/bin/ex6_mp_add_192`
- `build/bin/ex7_mp_sub_128`
- `build/bin/ex8_u64_to_str`
- `build/bin/ex9_parse_i64`
- `build/bin/ex10_int_div_to_double`
- `build/bin/ex11_parse_i64_range`
- `build/bin/tp1_driver`
