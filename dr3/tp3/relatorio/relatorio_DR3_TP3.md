# Relatório Técnico - DR3 TP3

Aluno: Renato Noronha Hack  
Disciplina: Verilog Avançado e Arquiteturas FPGA  
Projeto: Núcleo Aritmético Parametrizável em FPGA  
Placa: Tang Nano 9K  

Este Markdown é a versão textual do relatório. A versão final diagramada foi gerada em `relatorio/relatorio_DR3_TP3.pdf` a partir de `relatorio/relatorio_DR3_TP3.html`.

## 1. Resumo

O projeto implementa um núcleo aritmético parametrizável em Verilog HDL para a Tang Nano 9K. O núcleo suporta quatro modos numéricos: inteiro sem sinal de 8 bits, inteiro com sinal em complemento de dois, ponto fixo assinado `Q3.4` e ponto flutuante simplificado `E4M3`, inspirado no padrão IEEE-754.

O núcleo foi organizado em unidades independentes e integrado em um módulo de topo demonstrativo. Como a montagem disponível não possui display de sete segmentos, a validação física usa quatro botões externos no protoboard, quatro LEDs onboard e uma saída UART em 115200 8N1 para exibir operandos, resultado, flags e status PASS/FAIL.

## 2. Formatos numéricos

| Modo | Código | Formato | Faixa principal | Observação |
| --- | --- | --- | --- | --- |
| Inteiro sem sinal | `00` | `uint8` | 0 a 255 | Operações módulo 8 bits, com flag de overflow/underflow. |
| Inteiro com sinal | `01` | `int8` complemento de dois | -128 a 127 | Resultado em 8 bits, flags indicam estouro positivo ou negativo. |
| Ponto fixo | `10` | `Q3.4` assinado | -8.0000 a 7.9375 | 1 bit de sinal, 3 bits inteiros e 4 bits fracionários. |
| Ponto flutuante | `11` | `E4M3` | normalizado, bias 7 | 1 bit de sinal, 4 de expoente e 3 de mantissa. |

No formato `Q3.4`, o valor real é calculado por:

```text
valor = inteiro_com_sinal / 16
```

Assim, `18h` representa `1.5`, `08h` representa `0.5` e `80h` representa `-8.0`.

No formato `E4M3`, os campos são:

```text
[7]     sinal
[6:3]   expoente com bias 7
[2:0]   fração da mantissa
```

Valores com expoente `1111` e fração zero representam infinito. Subnormais não são preservados como resultado; resultados abaixo do menor normal são convertidos para zero com flags de underflow e inexatidão.

## 3. Arquitetura

| Módulo | Função |
| --- | --- |
| `int_unsigned_alu` | Soma, subtração, multiplicação e divisão para inteiros sem sinal. |
| `int_signed_alu` | Soma, subtração, multiplicação e divisão para inteiros em complemento de dois. |
| `fixed_q3_4_alu` | Operações em ponto fixo `Q3.4`, com saturação em overflow/underflow. |
| `minifloat_e4m3_addsub` | Soma/subtração em ponto flutuante `E4M3`, com alinhamento, normalização e exceções básicas. |
| `arithmetic_core` | Multiplexa as unidades conforme `mode` e `op`. |
| `tp3_demo_vectors` | Vetores demonstrativos e valores esperados usados pelo top físico. |
| `tp3_demo_top` | Integra botões, LEDs, UART e núcleo aritmético. |

Operações:

| `op` | Operação |
| --- | --- |
| `00` | Soma |
| `01` | Subtração |
| `10` | Multiplicação |
| `11` | Divisão |

Para ponto flutuante `E4M3`, apenas soma e subtração são implementadas. Multiplicação e divisão retornam `unsupported`.

Flags:

| Bit | Nome | Significado |
| ---: | --- | --- |
| 0 | overflow | Resultado acima do máximo representável. |
| 1 | underflow | Resultado abaixo do mínimo representável. |
| 2 | div_zero | Divisão por zero. |
| 3 | saturation | Resultado foi saturado no limite do formato. |
| 4 | unsupported | Operação não implementada para o modo selecionado. |
| 5 | inexact | Houve truncamento ou resto descartado. |

## 4. Integração com a Tang Nano 9K

O projeto Gowin está em `gowin/tp3_arithmetic_core.gprj`, usando o dispositivo `GW1NR-9C` (`GW1NR-LV9QN88PC6/I5`).

Mapeamento de pinos:

| Sinal | Pino | Uso |
| --- | ---: | --- |
| `sys_clk` | 52 | Clock onboard. |
| `sys_rst_n` | 4 | Reset ativo em nível baixo. |
| `btn_n[0]` | 25 | Troca modo numérico. |
| `btn_n[1]` | 26 | Troca operação. |
| `btn_n[2]` | 27 | Troca vetor de teste. |
| `btn_n[3]` | 28 | Retransmite a linha UART atual. |
| `led_n[0]` | 10 | PASS do vetor atual. |
| `led_n[1]` | 11 | Alguma flag ativa. |
| `led_n[2]` | 13 | Bit 0 do modo. |
| `led_n[3]` | 14 | Bit 1 do modo. |
| `uart_tx` | 17 | Saída serial 115200 8N1. |

Formato da linha UART:

```text
TP3 mode=<formato> op=<operação> case=<n> A=<hex> B=<hex> result=<hex> flags=<hex+texto> pass=<YES/NO>
```

Exemplo do reset:

```text
TP3 mode=UINT8  op=ADD case=0 A=0C B=05 result=11 flags=00 OK        pass=YES
```

## 5. Testbenches

As simulações foram executadas com Icarus Verilog:

```bash
./sim/run_all.sh
```

Testbenches:

| Testbench | Cobertura |
| --- | --- |
| `tb_int_unsigned_alu` | Soma, subtração, multiplicação, divisão, overflow, underflow, divisão por zero e inexatidão. |
| `tb_int_signed_alu` | Operações assinadas, overflow positivo, underflow negativo, divisão inexata e caso `-128 / -1`. |
| `tb_fixed_q3_4_alu` | Operações `Q3.4`, saturação positiva/negativa, truncamento e divisão por zero. |
| `tb_minifloat_e4m3_addsub` | Soma/subtração `E4M3`, cancelamento, overflow para infinito e underflow para zero. |
| `tb_arithmetic_core` | Varredura de todos os modos, operações e vetores demonstrativos. |
| `tb_tp3_demo_top` | Reset, botões, LEDs e transmissão UART do top da Tang. |

Resultado das simulações:

```text
All simulations completed.
```

Os logs foram salvos em `evidencias/simulacao/*.log`, e os VCDs foram salvos em `sim/build/*.vcd` e copiados para `evidencias/simulacao/*.vcd`.

## 6. Interpretação das formas de onda

No testbench `tb_arithmetic_core`, a forma de onda mostra a varredura de `mode`, `op` e `case_id`. Para cada combinação, os sinais `a`, `b`, `result` e `flags` são comparados com `expected` e `expected_flags`. O contador `errors` permanece em zero durante toda a simulação.

No testbench `tb_fixed_q3_4_alu`, os casos de saturação aparecem quando o resultado matemático excede `7Fh` ou fica abaixo de `80h`. Nessas situações, `flags[3]` indica saturação, enquanto `flags[0]` ou `flags[1]` indicam overflow ou underflow. O caso de multiplicação `05h * 05h` evidencia truncamento com `flags[5] = 1`.

No testbench `tb_minifloat_e4m3_addsub`, `77h + 77h` gera `78h`, isto é, infinito positivo, com `overflow`. Os casos com diferença menor que o menor normal geram `00h` com underflow e inexatidão. O cancelamento exato `1.0 + (-1.0)` gera zero sem flag.

No testbench `tb_tp3_demo_top`, os pulsos em `button_pulse` alteram `mode`, `op` e `case_id`. O sinal `uart_tx` transmite linhas ASCII contendo os operandos e resultados. O sinal `led_n[0]` fica em zero quando `pass = 1`, e `led_n[1]` fica em zero quando alguma flag está ativa.

## 7. Evidências

Evidências automáticas geradas:

| Evidência | Arquivo |
| --- | --- |
| Logs de simulação | `evidencias/simulacao/*.log` |
| VCDs | `evidencias/simulacao/*.vcd` |
| Savefiles GTKWave | `sim/waves/*.gtkw` |

Evidências finais incorporadas no relatório HTML/PDF:

| Evidência | Arquivo |
| --- | --- |
| Core integrado no GTKWave | `evidencias/waveforms/core_integrado_todos_modos.png` |
| Top, botões e UART no GTKWave | `evidencias/waveforms/top_uart_botoes.png` |
| Ponto fixo: saturação/truncamento | `evidencias/waveforms/fixed_saturacao_truncamento.png` |
| Ponto flutuante: overflow/underflow | `evidencias/waveforms/float_overflow_underflow.png` |
| Síntese Gowin | `evidencias/gowin/sintese_ok.png` |
| Place & Route Gowin | `evidencias/gowin/place_route_ok.png` |
| Programação SRAM | `evidencias/gowin/programacao_sram_ok.png` |
| Recursos Gowin | `evidencias/gowin/relatorio_recursos.txt` |
| Montagem física | `evidencias/hardware/montagem_botoes.jpg` |
| Estado inicial nos LEDs | `evidencias/hardware/leds_estado_inicial.jpg` |
| Overflow nos LEDs | `evidencias/hardware/leds_overflow.jpg` |
| Saturação nos LEDs | `evidencias/hardware/leds_saturacao.jpg` |
| Terminal serial | `evidencias/hardware/serial_uart_resultados.png` |

O relatório final diagramado em `relatorio/relatorio_DR3_TP3.html` e `relatorio/relatorio_DR3_TP3.pdf` incorpora essas evidências diretamente como figuras, com legendas explicando o que cada print/foto demonstra.

## 8. Conclusão

O núcleo aritmético atende aos requisitos do TP3: possui formatos numéricos documentados, unidades aritméticas modulares, tratamento de overflow/underflow/saturação/inexatidão, testbenches com casos de borda e integração física para a Tang Nano 9K. A validação por simulação foi concluída com sucesso, o projeto foi sintetizado, posicionado/roteado e programado em SRAM no Gowin, e a execução em hardware foi evidenciada por LEDs, botões externos e UART com resultados `pass=YES`.
