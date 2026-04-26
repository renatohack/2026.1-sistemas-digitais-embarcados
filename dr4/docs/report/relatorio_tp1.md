# Relatorio Tecnico - TP1

## Identificacao

- Aluno: `TODO`
- Matricula: `TODO`
- Disciplina: Processamento Otimizado em Assembly ARM 64-bits
- Trabalho: TP1
- Hardware alvo final: Raspberry Pi Zero 2W
- Validacao preliminar: `qemu-aarch64` no host `x86_64`

## Visao Geral

Este projeto implementa as rotinas pedidas no TP1 em Assembly ARM64, com harnesses de teste em C para facilitar a validacao funcional, a inspecao por `objdump` e a reproducao da execucao tanto no Raspberry Pi Zero 2W quanto no ambiente local com QEMU.

As decisoes principais foram:

- organizar cada rotina em um modulo Assembly proprio;
- criar um executavel separado para cada exercicio pratico que exige saida observavel;
- manter um `Makefile` unico e modular, com deteccao automatica de compilacao cruzada no host e compilacao nativa no Raspberry;
- automatizar a geracao das evidencias em caminhos fixos dentro de `evidence/raspberry/`.

## Estrutura do Projeto

- `src/asm/`: `soc_addrs.s`, `mp_add_192.s`, `mp_sub_128.s`, `u64_to_str.s`, `parse_i64.s`, `int_div_to_double.s`, `parse_i64_range.s`
- `src/c/`: harnesses de teste e `tp1_driver.c`
- `scripts/`: automacao de execucao, `objdump` e GDB
- `docs/reference/pinagem_bcm_raspberry_pi_zero_2w.md`: tabela tecnica de pinagem
- `evidence/raspberry/`: destino padrao das evidencias finais no hardware real

## Exercício 1 - Pinagem e mapeamento BCM

O mapeamento entre pino fisico e numeracao BCM foi consolidado em [docs/reference/pinagem_bcm_raspberry_pi_zero_2w.md](../reference/pinagem_bcm_raspberry_pi_zero_2w.md). A tabela separa claramente pinos de alimentacao/terra e pinos de GPIO.

Justificativa tecnica: o cabecalho fisico e usado para ligacao em bancada, enquanto o software precisa operar com o numero BCM ao configurar ou consultar registradores de GPIO. A documentacao do projeto, portanto, registra sempre ambos os identificadores.

Placeholder de evidencia final:
`docs/reference/pinagem_bcm_raspberry_pi_zero_2w.md`

## Exercício 2 - Enderecos base do SoC

Foi criado o modulo `src/asm/soc_addrs.s`, que define e carrega em registradores os seguintes enderecos fisicos:

- `PERIPH_BASE = 0x3F000000`
- `GPIO_BASE = 0x3F200000`
- `UART0_BASE = 0x3F201000`
- `SYS_TIMER_BASE = 0x3F003000`
- `GPIO_GPFSEL1 = 0x3F200004`

Esses valores sao usados como base para a camada de MMIO do projeto. O executavel de validacao e `build/bin/ex2_soc_addrs`.

Validacao preliminar em QEMU:

- todas as constantes foram carregadas corretamente;
- `objdump` mostra instrucoes `mov/movk` coerentes com os enderecos adotados.

Evidencias finais esperadas:

- saida de execucao: `evidence/raspberry/ex02/ex2_soc_addrs_output.txt`
- objdump completo: `evidence/raspberry/ex02/ex2_soc_addrs_objdump.txt`

## Exercício 3 - Makefile modular

O projeto possui um `Makefile` unico com os alvos:

- `all`: compila todos os executaveis;
- `run`: executa o driver final do Ex. 12;
- `test`: executa toda a suite de validacao;
- `clean`: remove os artefatos de build.

A modularidade vem da separacao entre:

- objetos de C em `build/obj/c/`;
- objetos de Assembly em `build/obj/asm/`;
- executaveis finais em `build/bin/`.

Como o `make` usa dependencias por arquivo, apenas os modulos alterados sao recompilados nas execucoes seguintes.

Evidencias finais esperadas:

- limpeza: `evidence/raspberry/ex03/make_clean.txt`
- compilacao: `evidence/raspberry/ex03/make_build.txt`

## Exercício 4 - Depuracao com GDB

Para demonstrar registradores gerais e flags do `PSTATE`, foi escolhida a rotina `mp_sub_128`, no caso de teste com borrow. Essa escolha permite observar o efeito da primeira `subs` e da segunda `sbcs` de forma objetiva.

Pontos observados:

- entrada da funcao `mp_sub_128`;
- estado apos a subtracao da word menos significativa;
- estado apos a subtracao da word mais significativa.

A rotina de captura automatica foi preparada para gerar a transcricao em:

- `evidence/raspberry/ex04/gdb_mp_sub_128_borrow.txt`

Observacao: a mesma sessao tambem atende ao Exercicio 7, pois documenta explicitamente o comportamento de borrow.

## Exercício 5 - Decomposicao do binario com objdump

O binario `build/bin/tp1_driver` foi escolhido para auditoria porque ele integra varias rotinas Assembly do projeto. A validacao procura:

- `main`
- `mp_add_192`
- `parse_i64`
- `u64_to_str`
- `int_div_to_double`
- `parse_i64_range`

O criterio adotado foi confirmar:

- a presenca dos simbolos no binario final;
- as chamadas do `main` para as rotinas integradas;
- coerencia entre os nomes dos modulos e a decomposicao apresentada.

Evidencia final esperada:

- `evidence/raspberry/ex05/tp1_driver_objdump.txt`

## Exercício 6 - Soma multi-palavra de 192 bits

Arquivo principal: `src/asm/mp_add_192.s`

Contrato adotado:

- entrada em memoria little-endian por words de 64 bits;
- `word0` representa a parte menos significativa;
- retorno do carry final em `x0`.

Casos cobertos na validacao:

- sem carry;
- carry apenas de `word0 -> word1`;
- carry propagando ate `word2`;
- overflow final de 192 bits.

Validacao preliminar em QEMU: todos os casos passaram.

Evidencia final esperada:

- `evidence/raspberry/ex06/ex6_mp_add_192_output.txt`

## Exercício 7 - Subtracao multi-palavra de 128 bits

Arquivo principal: `src/asm/mp_sub_128.s`

Contrato adotado:

- entrada em memoria little-endian por words de 64 bits;
- `word0` representa a parte menos significativa;
- retorno de underflow/borrow final em `x0`, com `0 = sem borrow final` e `1 = com borrow final`.

Casos cobertos:

- subtracao sem borrow final;
- subtracao com borrow final.

A evidencia de GDB do Exercicio 4 tambem serve aqui, pois captura explicitamente o estado das flags apos a primeira e a segunda subtracao.

Evidencias finais esperadas:

- execucao: `evidence/raspberry/ex07/ex7_mp_sub_128_output.txt`
- GDB: `evidence/raspberry/ex07/gdb_mp_sub_128_borrow.txt`

## Exercício 8 - Conversao inteiro -> string

Arquivo principal: `src/asm/u64_to_str.s`

Contrato adotado:

- entrada: `uint64_t value`, ponteiro para buffer e tamanho do buffer;
- saida: string decimal ASCII terminada em `\0`;
- retorno: quantidade de caracteres sem contar `\0`;
- politica para buffer insuficiente: string vazia e retorno `0`.

Tamanho minimo garantido para qualquer `uint64_t`: 21 bytes.

Casos validados:

- `0`
- valor de 1 digito
- valor de multiplos digitos
- `UINT64_MAX`

Evidencia final esperada:

- `evidence/raspberry/ex08/ex8_u64_to_str_output.txt`

## Exercício 9 - Conversao string -> inteiro

Arquivo principal: `src/asm/parse_i64.s`

Contrato adotado:

- entrada: ponteiro para string ASCII;
- suporte a sinal `+` e `-` apenas no primeiro caractere;
- saida: valor convertido em memoria e status em `w0`.

Codigos de status:

- `0`: OK
- `1`: EMPTY
- `2`: INVALID
- `3`: OVERFLOW

Casos validados:

- `"0"`
- `"42"`
- `"-7"`
- `"+15"`
- string invalida com letras
- string vazia

Evidencia final esperada:

- `evidence/raspberry/ex09/ex9_parse_i64_output.txt`

## Exercício 10 - Conversao para double e divisao

Arquivo principal: `src/asm/int_div_to_double.s`

Contrato adotado:

- recebe dois inteiros signed 64-bit;
- converte ambos com `scvtf`;
- divide com `fdiv`;
- grava o resultado em `double *out`;
- em `b = 0`, retorna `DIV_BY_ZERO` e grava `0.0`.

Casos validados:

- `7 / 2 = 3.5`
- `-9 / 4 = -2.25`
- `5 / 0` como erro controlado

Evidencia final esperada:

- `evidence/raspberry/ex10/ex10_int_div_to_double_output.txt`

## Exercício 11 - Parsing com validacao de faixa

Arquivo principal: `src/asm/parse_i64_range.s`

Faixa adotada no codigo:

- `MIN = -1000`
- `MAX = 1000`

Politica de status:

- `0`: OK
- `2`: INVALID
- `4`: OUT_OF_RANGE

Casos validados:

- dentro da faixa
- abaixo do minimo
- acima do maximo
- string invalida
- string vazia
- valor com sinal

Evidencia final esperada:

- `evidence/raspberry/ex11/ex11_parse_i64_range_output.txt`

## Exercício 12 - Integracao final

O driver final esta em `src/c/tp1_driver.c` e gera o executavel `build/bin/tp1_driver`.

Rotinas integradas no driver:

- `mp_add_192`
- `parse_i64`
- `u64_to_str`
- `int_div_to_double`
- `parse_i64_range`

Saida esperada do driver:

- indica sucesso ou falha em cada chamada;
- retorna codigo `0` quando todas as verificacoes passam.

Evidencias finais esperadas:

- saida do driver: `evidence/raspberry/ex12/ex12_driver_output.txt`
- symbols/objdump: `evidence/raspberry/ex12/tp1_driver_symbols.txt`
- transcricao completa da suite: `evidence/raspberry/ex12/full_test_suite_output.txt`

## Resumo da Validacao Preliminar em QEMU

Situacao atual antes da rodada final no Raspberry:

- `make`: PASS
- `make test`: PASS
- `make run`: PASS
- `objdump` dos binarios principais: PASS
- depuracao GDB sobre o caso de borrow: PASS

## Checklist de Evidencias Finais

- Ex2: `evidence/raspberry/ex02/ex2_soc_addrs_output.txt`
- Ex2: `evidence/raspberry/ex02/ex2_soc_addrs_objdump.txt`
- Ex3: `evidence/raspberry/ex03/make_clean.txt`
- Ex3: `evidence/raspberry/ex03/make_build.txt`
- Ex4: `evidence/raspberry/ex04/gdb_mp_sub_128_borrow.txt`
- Ex5: `evidence/raspberry/ex05/tp1_driver_objdump.txt`
- Ex6: `evidence/raspberry/ex06/ex6_mp_add_192_output.txt`
- Ex7: `evidence/raspberry/ex07/ex7_mp_sub_128_output.txt`
- Ex7: `evidence/raspberry/ex07/gdb_mp_sub_128_borrow.txt`
- Ex8: `evidence/raspberry/ex08/ex8_u64_to_str_output.txt`
- Ex9: `evidence/raspberry/ex09/ex9_parse_i64_output.txt`
- Ex10: `evidence/raspberry/ex10/ex10_int_div_to_double_output.txt`
- Ex11: `evidence/raspberry/ex11/ex11_parse_i64_range_output.txt`
- Ex12: `evidence/raspberry/ex12/ex12_driver_output.txt`
- Ex12: `evidence/raspberry/ex12/tp1_driver_symbols.txt`
- Ex12: `evidence/raspberry/ex12/full_test_suite_output.txt`
