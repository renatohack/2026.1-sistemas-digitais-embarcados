# Relatorio Tecnico - DR3 TP3

Aluno: Renato Noronha Hack  
Disciplina: Verilog Avancado e Arquiteturas FPGA  
Projeto: Nucleo Aritmetico Parametrizavel em FPGA  
Placa: Tang Nano 9K  

Este Markdown e a versao textual do relatorio. A versao final diagramada foi gerada em `relatorio/relatorio_DR3_TP3.pdf` a partir de `relatorio/relatorio_DR3_TP3.html`.

## 1. Resumo

O projeto implementa um nucleo aritmetico parametrizavel em Verilog HDL para a Tang Nano 9K. O nucleo suporta quatro modos numericos: inteiro sem sinal de 8 bits, inteiro com sinal em complemento de dois, ponto fixo assinado `Q3.4` e ponto flutuante simplificado `E4M3`, inspirado no padrao IEEE-754.

O nucleo foi organizado em unidades independentes e integrado em um modulo de topo demonstrativo. Como a montagem disponivel nao possui display de sete segmentos, a validacao fisica usa quatro botoes externos no protoboard, quatro LEDs onboard e uma saida UART em 115200 8N1 para exibir operandos, resultado, flags e status PASS/FAIL.

## 2. Formatos numericos

| Modo | Codigo | Formato | Faixa principal | Observacao |
| --- | --- | --- | --- | --- |
| Inteiro sem sinal | `00` | `uint8` | 0 a 255 | Operacoes modulo 8 bits, com flag de overflow/underflow. |
| Inteiro com sinal | `01` | `int8` complemento de dois | -128 a 127 | Resultado em 8 bits, flags indicam estouro positivo ou negativo. |
| Ponto fixo | `10` | `Q3.4` assinado | -8.0000 a 7.9375 | 1 bit de sinal, 3 bits inteiros e 4 bits fracionarios. |
| Ponto flutuante | `11` | `E4M3` | normalizado, bias 7 | 1 bit de sinal, 4 de expoente e 3 de mantissa. |

No formato `Q3.4`, o valor real e calculado por:

```text
valor = inteiro_com_sinal / 16
```

Assim, `18h` representa `1.5`, `08h` representa `0.5` e `80h` representa `-8.0`.

No formato `E4M3`, os campos sao:

```text
[7]     sinal
[6:3]   expoente com bias 7
[2:0]   fracao da mantissa
```

Valores com expoente `1111` e fracao zero representam infinito. Subnormais nao sao preservados como resultado; resultados abaixo do menor normal sao convertidos para zero com flags de underflow e inexatidao.

## 3. Arquitetura

| Modulo | Funcao |
| --- | --- |
| `int_unsigned_alu` | Soma, subtracao, multiplicacao e divisao para inteiros sem sinal. |
| `int_signed_alu` | Soma, subtracao, multiplicacao e divisao para inteiros em complemento de dois. |
| `fixed_q3_4_alu` | Operacoes em ponto fixo `Q3.4`, com saturacao em overflow/underflow. |
| `minifloat_e4m3_addsub` | Soma/subtracao em ponto flutuante `E4M3`, com alinhamento, normalizacao e excecoes basicas. |
| `arithmetic_core` | Multiplexa as unidades conforme `mode` e `op`. |
| `tp3_demo_vectors` | Vetores demonstrativos e valores esperados usados pelo top fisico. |
| `tp3_demo_top` | Integra botoes, LEDs, UART e nucleo aritmetico. |

Operacoes:

| `op` | Operacao |
| --- | --- |
| `00` | Soma |
| `01` | Subtracao |
| `10` | Multiplicacao |
| `11` | Divisao |

Para ponto flutuante `E4M3`, apenas soma e subtracao sao implementadas. Multiplicacao e divisao retornam `unsupported`.

Flags:

| Bit | Nome | Significado |
| ---: | --- | --- |
| 0 | overflow | Resultado acima do maximo representavel. |
| 1 | underflow | Resultado abaixo do minimo representavel. |
| 2 | div_zero | Divisao por zero. |
| 3 | saturation | Resultado foi saturado no limite do formato. |
| 4 | unsupported | Operacao nao implementada para o modo selecionado. |
| 5 | inexact | Houve truncamento ou resto descartado. |

## 4. Integracao com a Tang Nano 9K

O projeto Gowin esta em `gowin/tp3_arithmetic_core.gprj`, usando o dispositivo `GW1NR-9C` (`GW1NR-LV9QN88PC6/I5`).

Mapeamento de pinos:

| Sinal | Pino | Uso |
| --- | ---: | --- |
| `sys_clk` | 52 | Clock onboard. |
| `sys_rst_n` | 4 | Reset ativo em nivel baixo. |
| `btn_n[0]` | 25 | Troca modo numerico. |
| `btn_n[1]` | 26 | Troca operacao. |
| `btn_n[2]` | 27 | Troca vetor de teste. |
| `btn_n[3]` | 28 | Retransmite a linha UART atual. |
| `led_n[0]` | 10 | PASS do vetor atual. |
| `led_n[1]` | 11 | Alguma flag ativa. |
| `led_n[2]` | 13 | Bit 0 do modo. |
| `led_n[3]` | 14 | Bit 1 do modo. |
| `uart_tx` | 17 | Saida serial 115200 8N1. |

Formato da linha UART:

```text
TP3 mode=<formato> op=<operacao> case=<n> A=<hex> B=<hex> result=<hex> flags=<hex+texto> pass=<YES/NO>
```

Exemplo do reset:

```text
TP3 mode=UINT8  op=ADD case=0 A=0C B=05 result=11 flags=00 OK        pass=YES
```

## 5. Testbenches

As simulacoes foram executadas com Icarus Verilog:

```bash
./sim/run_all.sh
```

Testbenches:

| Testbench | Cobertura |
| --- | --- |
| `tb_int_unsigned_alu` | Soma, subtracao, multiplicacao, divisao, overflow, underflow, divisao por zero e inexatidao. |
| `tb_int_signed_alu` | Operacoes assinadas, overflow positivo, underflow negativo, divisao inexata e caso `-128 / -1`. |
| `tb_fixed_q3_4_alu` | Operacoes `Q3.4`, saturacao positiva/negativa, truncamento e divisao por zero. |
| `tb_minifloat_e4m3_addsub` | Soma/subtracao `E4M3`, cancelamento, overflow para infinito e underflow para zero. |
| `tb_arithmetic_core` | Varredura de todos os modos, operacoes e vetores demonstrativos. |
| `tb_tp3_demo_top` | Reset, botoes, LEDs e transmissao UART do top da Tang. |

Resultado das simulacoes:

```text
All simulations completed.
```

Os logs foram salvos em `evidencias/simulacao/*.log`, e os VCDs foram salvos em `sim/build/*.vcd` e copiados para `evidencias/simulacao/*.vcd`.

## 6. Interpretacao das formas de onda

No testbench `tb_arithmetic_core`, a forma de onda mostra a varredura de `mode`, `op` e `case_id`. Para cada combinacao, os sinais `a`, `b`, `result` e `flags` sao comparados com `expected` e `expected_flags`. O contador `errors` permanece em zero durante toda a simulacao.

No testbench `tb_fixed_q3_4_alu`, os casos de saturacao aparecem quando o resultado matematico excede `7Fh` ou fica abaixo de `80h`. Nessas situacoes, `flags[3]` indica saturacao, enquanto `flags[0]` ou `flags[1]` indicam overflow ou underflow. O caso de multiplicacao `05h * 05h` evidencia truncamento com `flags[5] = 1`.

No testbench `tb_minifloat_e4m3_addsub`, `77h + 77h` gera `78h`, isto e, infinito positivo, com `overflow`. Os casos com diferenca menor que o menor normal geram `00h` com underflow e inexatidao. O cancelamento exato `1.0 + (-1.0)` gera zero sem flag.

No testbench `tb_tp3_demo_top`, os pulsos em `button_pulse` alteram `mode`, `op` e `case_id`. O sinal `uart_tx` transmite linhas ASCII contendo os operandos e resultados. O sinal `led_n[0]` fica em zero quando `pass = 1`, e `led_n[1]` fica em zero quando alguma flag esta ativa.

## 7. Evidencias

Evidencias automaticas ja geradas:

| Evidencia | Arquivo |
| --- | --- |
| Logs de simulacao | `evidencias/simulacao/*.log` |
| VCDs | `evidencias/simulacao/*.vcd` |
| Savefiles GTKWave | `sim/waves/*.gtkw` |

Evidencias manuais pendentes:

| Evidencia | Caminho esperado |
| --- | --- |
| Core integrado no GTKWave | `evidencias/waveforms/core_integrado_todos_modos.png` |
| Top, botoes e UART no GTKWave | `evidencias/waveforms/top_uart_botoes.png` |
| Ponto fixo: saturacao/truncamento | `evidencias/waveforms/fixed_saturacao_truncamento.png` |
| Ponto flutuante: overflow/underflow | `evidencias/waveforms/float_overflow_underflow.png` |
| Sintese Gowin | `evidencias/gowin/sintese_ok.png` |
| Place & Route Gowin | `evidencias/gowin/place_route_ok.png` |
| Programacao SRAM | `evidencias/gowin/programacao_sram_ok.png` |
| Recursos Gowin | `evidencias/gowin/relatorio_recursos.txt` |
| Montagem fisica | `evidencias/hardware/montagem_botoes.jpg` |
| Estado inicial nos LEDs | `evidencias/hardware/leds_estado_inicial.jpg` |
| Overflow nos LEDs | `evidencias/hardware/leds_overflow.jpg` |
| Saturacao nos LEDs | `evidencias/hardware/leds_saturacao.jpg` |
| Terminal serial | `evidencias/hardware/serial_uart_resultados.png` |

Os passos exatos para gerar cada evidencia manual estao em `GUIA_EVIDENCIAS_DR3_TP3.md`.

## 8. Conclusao

O nucleo aritmetico atende aos requisitos do TP3: possui formatos numericos documentados, unidades aritmeticas modulares, tratamento de overflow/underflow/saturacao/inexatidao, testbenches com casos de borda e integracao fisica para a Tang Nano 9K. A validacao por simulacao foi concluida com sucesso. As evidencias fisicas dependem da sintese no Gowin e da execucao na placa real.
