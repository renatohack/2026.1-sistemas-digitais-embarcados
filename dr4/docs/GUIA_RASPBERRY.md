# Guia de Execucao no Raspberry Pi Zero 2W

Este guia foi pensado para minimizar trabalho manual. A ideia e:

1. copiar o projeto para o Raspberry;
2. instalar dependencias basicas, se necessario;
3. rodar um script unico;
4. usar os arquivos gerados em `evidence/raspberry/` como base para fechar o relatorio.

## 1. Preparacao inicial

Entre na pasta do projeto:

```bash
cd /caminho/para/dr4
```

Confirme que voce esta em ARM64:

```bash
uname -m
```

Saida esperada: `aarch64`

## 2. Dependencias minimas

Se o Raspberry ainda nao tiver ferramentas basicas:

```bash
sudo apt update
sudo apt install -y build-essential gdb binutils
```

## 3. Fluxo recomendado: captura automatica de tudo

Rode:

```bash
./scripts/raspberry/capture_raspberry_evidence.sh
```

Esse comando vai:

- limpar o build anterior;
- compilar todos os binarios;
- executar cada exercicio validavel;
- executar o driver final;
- gerar `objdump`;
- rodar a sessao de GDB do caso com borrow;
- salvar tudo automaticamente dentro de `evidence/raspberry/`.

## 4. Comandos manuais por etapa

Se quiser rodar passo a passo, use esta sequencia.

### 4.1 Limpeza e compilacao

```bash
make clean > evidence/raspberry/ex03/make_clean.txt 2>&1
make > evidence/raspberry/ex03/make_build.txt 2>&1
```

### 4.2 Exercício 2

```bash
build/bin/ex2_soc_addrs > evidence/raspberry/ex02/ex2_soc_addrs_output.txt
objdump -d build/bin/ex2_soc_addrs > evidence/raspberry/ex02/ex2_soc_addrs_objdump.txt
```

### 4.3 Exercício 6

```bash
build/bin/ex6_mp_add_192 > evidence/raspberry/ex06/ex6_mp_add_192_output.txt
```

### 4.4 Exercício 7

```bash
build/bin/ex7_mp_sub_128 > evidence/raspberry/ex07/ex7_mp_sub_128_output.txt
./scripts/raspberry/run_native_gdb_ex7.sh
```

### 4.5 Exercício 8

```bash
build/bin/ex8_u64_to_str > evidence/raspberry/ex08/ex8_u64_to_str_output.txt
```

### 4.6 Exercício 9

```bash
build/bin/ex9_parse_i64 > evidence/raspberry/ex09/ex9_parse_i64_output.txt
```

### 4.7 Exercício 10

```bash
build/bin/ex10_int_div_to_double > evidence/raspberry/ex10/ex10_int_div_to_double_output.txt
```

### 4.8 Exercício 11

```bash
build/bin/ex11_parse_i64_range > evidence/raspberry/ex11/ex11_parse_i64_range_output.txt
```

### 4.9 Exercício 12

```bash
build/bin/tp1_driver > evidence/raspberry/ex12/ex12_driver_output.txt
./scripts/run_test_suite.sh > evidence/raspberry/ex12/full_test_suite_output.txt
objdump -d build/bin/tp1_driver > evidence/raspberry/ex05/tp1_driver_objdump.txt
objdump -t build/bin/tp1_driver > evidence/raspberry/ex12/tp1_driver_symbols.txt
```

## 5. Arquivos que o relatorio vai esperar

- `evidence/raspberry/ex02/ex2_soc_addrs_output.txt`
- `evidence/raspberry/ex02/ex2_soc_addrs_objdump.txt`
- `evidence/raspberry/ex03/make_clean.txt`
- `evidence/raspberry/ex03/make_build.txt`
- `evidence/raspberry/ex04/gdb_mp_sub_128_borrow.txt`
- `evidence/raspberry/ex05/tp1_driver_objdump.txt`
- `evidence/raspberry/ex06/ex6_mp_add_192_output.txt`
- `evidence/raspberry/ex07/ex7_mp_sub_128_output.txt`
- `evidence/raspberry/ex07/gdb_mp_sub_128_borrow.txt`
- `evidence/raspberry/ex08/ex8_u64_to_str_output.txt`
- `evidence/raspberry/ex09/ex9_parse_i64_output.txt`
- `evidence/raspberry/ex10/ex10_int_div_to_double_output.txt`
- `evidence/raspberry/ex11/ex11_parse_i64_range_output.txt`
- `evidence/raspberry/ex12/ex12_driver_output.txt`
- `evidence/raspberry/ex12/tp1_driver_symbols.txt`
- `evidence/raspberry/ex12/full_test_suite_output.txt`

## 6. Video

Para o video, a sugestao pratica e mostrar:

1. `make`
2. `make run`
3. um ou dois executaveis individuais
4. `gdb` via `./scripts/raspberry/run_native_gdb_ex7.sh`
5. um trecho de `objdump -d build/bin/tp1_driver`
