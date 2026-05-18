# Guia de Evidencias - DR3 TP3

Este guia lista as evidencias que faltam gerar manualmente e os caminhos finais onde elas devem ser salvas. O ZIP final nao foi gerado por projeto.

## 1. Evidencias ja geradas automaticamente

Rode novamente, se precisar atualizar:

```bash
./sim/run_all.sh
```

Arquivos ja gerados:

- Logs: `evidencias/simulacao/*.log`
- VCDs: `sim/build/*.vcd`
- Copia dos VCDs para entrega: `evidencias/simulacao/*.vcd`
- Projeto Gowin: `gowin/tp3_arithmetic_core.gprj`
- Relatorio tecnico base: `relatorio/relatorio_DR3_TP3.md`, `relatorio/relatorio_DR3_TP3.html`, `relatorio/relatorio_DR3_TP3.pdf`

Observacao: o relatorio atual e uma base tecnica. Depois que as imagens deste guia forem salvas, o relatorio final deve ser atualizado para incorporar as figuras diretamente no HTML/PDF.

## 2. Capturas GTKWave

### 2.1 Core integrado

Comando:

```bash
gtkwave sim/build/tb_arithmetic_core.vcd sim/waves/tb_arithmetic_core.gtkw
```

Sinais que devem aparecer:

- `tb_arithmetic_core.mode[1:0]`
- `tb_arithmetic_core.op[1:0]`
- `tb_arithmetic_core.case_id[1:0]`
- `tb_arithmetic_core.a[7:0]`
- `tb_arithmetic_core.b[7:0]`
- `tb_arithmetic_core.result[7:0]`
- `tb_arithmetic_core.expected[7:0]`
- `tb_arithmetic_core.flags[5:0]`
- `tb_arithmetic_core.expected_flags[5:0]`
- `tb_arithmetic_core.errors[31:0]`

Momento da captura:

- Use zoom de `0 ns` a `64 ns`.
- Posicione o cursor perto de `49 ns`, onde comeca o modo `11` de ponto flutuante.
- A imagem deve mostrar `mode`, `op`, `case_id`, `result == expected`, `flags == expected_flags` e `errors = 0`.

Salvar como:

- `evidencias/waveforms/core_integrado_todos_modos.png`

### 2.2 Top com botoes, LEDs e UART

Comando:

```bash
gtkwave sim/build/tb_tp3_demo_top.vcd sim/waves/tb_tp3_demo_top.gtkw
```

Sinais que devem aparecer:

- `tb_tp3_demo_top.sys_clk`
- `tb_tp3_demo_top.sys_rst_n`
- `tb_tp3_demo_top.btn_n[3:0]`
- `tb_tp3_demo_top.dut.button_pulse[3:0]`
- `tb_tp3_demo_top.dut.mode[1:0]`
- `tb_tp3_demo_top.dut.op[1:0]`
- `tb_tp3_demo_top.dut.case_id[1:0]`
- `tb_tp3_demo_top.dut.a[7:0]`
- `tb_tp3_demo_top.dut.b[7:0]`
- `tb_tp3_demo_top.dut.result[7:0]`
- `tb_tp3_demo_top.dut.flags[5:0]`
- `tb_tp3_demo_top.dut.expected[7:0]`
- `tb_tp3_demo_top.dut.expected_flags[5:0]`
- `tb_tp3_demo_top.dut.pass`
- `tb_tp3_demo_top.led_n[3:0]`
- `tb_tp3_demo_top.uart_tx`
- `tb_tp3_demo_top.dut.uart_start`
- `tb_tp3_demo_top.dut.uart_busy`
- `tb_tp3_demo_top.dut.uart_data[7:0]`

Momento da captura:

- Use zoom de `0 us` a `170 us`.
- Posicione o cursor no pulso de `button_pulse[2]`, perto da terceira linha UART, onde o caso muda para `C1`.
- A imagem deve mostrar `btn_n`, `button_pulse`, mudanca de `case_id`, `led_n`, `uart_tx` e `uart_data`.

Salvar como:

- `evidencias/waveforms/top_uart_botoes.png`

### 2.3 Ponto fixo: saturacao e truncamento

Comando:

```bash
gtkwave sim/build/tb_fixed_q3_4_alu.vcd sim/waves/tb_numeric_units.gtkw
```

Sinais que devem aparecer:

- `tb_fixed_q3_4_alu.op[1:0]`
- `tb_fixed_q3_4_alu.a[7:0]`
- `tb_fixed_q3_4_alu.b[7:0]`
- `tb_fixed_q3_4_alu.result[7:0]`
- `tb_fixed_q3_4_alu.flags[5:0]`
- `tb_fixed_q3_4_alu.errors[31:0]`

Momento da captura:

- Use zoom de `0 ns` a `14 ns`.
- Posicione o cursor em `10 ns` para evidenciar multiplicacao com truncamento (`flags = 20h`) e mantenha visiveis os casos de saturacao em `2 ns`, `3 ns`, `8 ns` e `9 ns`.

Salvar como:

- `evidencias/waveforms/fixed_saturacao_truncamento.png`

### 2.4 Ponto flutuante E4M3: overflow e underflow

Comando:

```bash
gtkwave sim/build/tb_minifloat_e4m3_addsub.vcd sim/waves/tb_minifloat_e4m3_addsub.gtkw
```

Sinais que devem aparecer:

- `tb_minifloat_e4m3_addsub.op_sub`
- `tb_minifloat_e4m3_addsub.a[7:0]`
- `tb_minifloat_e4m3_addsub.b[7:0]`
- `tb_minifloat_e4m3_addsub.result[7:0]`
- `tb_minifloat_e4m3_addsub.flags[5:0]`
- `tb_minifloat_e4m3_addsub.errors[31:0]`

Momento da captura:

- Use zoom de `0 ns` a `8 ns`.
- Posicione o cursor em `2 ns` para overflow para infinito (`result = 78h`, `flags = 01h`) ou em `4 ns` para underflow para zero (`result = 00h`, `flags = 22h`).

Salvar como:

- `evidencias/waveforms/float_overflow_underflow.png`

## 3. Evidencias Gowin

Abra no Gowin:

```text
gowin/tp3_arithmetic_core.gprj
```

Confirme que o top e `tp3_demo_top`. Se o Gowin pedir selecao manual de top, escolha `tp3_demo_top`.

Passos:

1. Rode `Synthesis`.
2. Salve a tela de sucesso como `evidencias/gowin/sintese_ok.png`.
3. Rode `Place & Route`.
4. Salve a tela de sucesso como `evidencias/gowin/place_route_ok.png`.
5. Abra o relatorio de recursos, copie o resumo de LUTs/registradores/IOs e salve como `evidencias/gowin/relatorio_recursos.txt`.
6. Abra o Programmer, use SRAM Program e salve a tela de conclusao como `evidencias/gowin/programacao_sram_ok.png`.

## 4. Como ver a UART no terminal

A UART e uma saida serial de texto da FPGA. Ela funciona como um "printf" em hardware: toda vez que o sistema inicia ou voce aperta um botao, a Tang envia uma linha de texto pelo `uart_tx`.

Linha esperada no reset:

```text
TP3 mode=UINT8  op=ADD case=0 A=0C B=05 result=11 flags=00 OK        pass=YES
```

Interpretacao:

| Campo | Significado |
| --- | --- |
| `mode=UINT8` | Formato numerico atual: inteiro sem sinal de 8 bits. |
| `op=ADD` | Operacao atual: soma. |
| `case=0` | Vetor de teste selecionado. |
| `A=0C B=05` | Operandos em hexadecimal. |
| `result=11` | Resultado em hexadecimal. |
| `flags=00 OK` | Nenhuma flag de erro/limite. |
| `pass=YES` | Resultado e flags bateram com o esperado pelo vetor interno. |

Outros exemplos:

```text
TP3 mode=UINT8  op=ADD case=1 A=FA B=0A result=04 flags=01 OVERFLOW  pass=YES
TP3 mode=Q3.4   op=ADD case=1 A=78 B=10 result=7F flags=09 OVF+SAT   pass=YES
TP3 mode=E4M3   op=MUL case=0 A=38 B=30 result=00 flags=10 UNSUP     pass=YES
```

Abrindo o terminal no Linux:

1. Conecte a Tang Nano 9K via USB.
2. Veja quais portas seriais apareceram:

```bash
ls /dev/ttyUSB* /dev/ttyACM* 2>/dev/null
```

3. Abra uma delas em 115200 8N1. Tente primeiro `/dev/ttyUSB1`; se nao sair texto, feche e tente `/dev/ttyUSB0`.

```bash
screen /dev/ttyUSB1 115200
```

Para sair do `screen`: pressione `Ctrl+A`, depois `K`, depois confirme com `y`.

Alternativa com `tio`, se estiver instalado:

```bash
tio /dev/ttyUSB1 -b 115200
```

Para sair do `tio`: `Ctrl+T`, depois `q`.

Depois de abrir o terminal:

1. Programe a FPGA no Gowin.
2. Pressione reset na Tang.
3. Se nada aparecer, pressione BTN3, que retransmite a linha atual.
4. Se ainda nao aparecer, teste a outra porta `/dev/ttyUSB*`.

## 5. Montagem fisica

Nao use display de sete segmentos. O protoboard tera apenas os quatro botoes externos; os LEDs usados na demonstracao sao os LEDs onboard da Tang Nano 9K.

A ligacao correta e com GND comum. Nao ligue 3V3 nem 5V nos botoes. Os pinos 25 a 28 ja ficam em nivel alto por `PULL_MODE=UP`; quando o botao e pressionado, ele fecha contato para GND e o sinal vira `0`.

Resumo eletrico:

```text
Pino 25 ---- botao ---- GND
Pino 26 ---- botao ---- GND
Pino 27 ---- botao ---- GND
Pino 28 ---- botao ---- GND
```

Tabela:

| Botao fisico | Sinal no Verilog | Pino Tang | Funcao | Ligacao |
| --- | --- | ---: | --- | --- |
| BTN0 | `btn_n[0]` | 25 | Troca modo numerico | pino 25 -> botao -> GND |
| BTN1 | `btn_n[1]` | 26 | Troca operacao | pino 26 -> botao -> GND |
| BTN2 | `btn_n[2]` | 27 | Troca vetor/caso | pino 27 -> botao -> GND |
| BTN3 | `btn_n[3]` | 28 | Reenvia linha UART | pino 28 -> botao -> GND |

Montagem sugerida no protoboard pequeno:

1. Separe uma linha/trilho do protoboard para GND comum.
2. Ligue um pino GND da Tang Nano 9K nessa linha/trilho.
3. Coloque os quatro botoes no protoboard.
4. Em cada botao, ligue um lado ao GND comum.
5. Ligue o outro lado de cada botao ao respectivo pino 25, 26, 27 ou 28.

Se o seu botao for tactil de 4 pernas:

- As duas pernas do mesmo lado geralmente ja sao conectadas entre si.
- O contato fecha entre os lados opostos quando voce aperta.
- Coloque o botao atravessando o vao central do protoboard, se houver.
- Ligue um lado ao GND comum e o lado oposto ao pino da Tang.

Teste rapido com multimetro:

- Sem apertar: o pino do botao nao deve estar em curto com GND.
- Apertando: o pino deve ficar em curto com GND.

LEDs onboard:

| LED | Significado |
| --- | --- |
| LED0 | PASS do vetor atual |
| LED1 | Alguma flag ativa |
| LED2 | bit 0 do modo |
| LED3 | bit 1 do modo |

Como os LEDs sao ativos em nivel baixo, LED ligado corresponde a saida `0`.

Salvar foto da montagem como:

- `evidencias/hardware/montagem_botoes.jpg`

## 6. Evidencias de hardware

Abra o terminal serial em 115200 8N1 conforme a secao 4.

Depois de programar a FPGA:

1. Pressione reset.
2. Verifique a linha inicial:

```text
TP3 mode=UINT8  op=ADD case=0 A=0C B=05 result=11 flags=00 OK        pass=YES
```

3. Fotografe a placa com LED0 ligado e salve:

- `evidencias/hardware/leds_estado_inicial.jpg`

4. Pressione BTN2 uma vez para ir para o caso `mode=UINT8 op=ADD case=1`, que gera overflow unsigned:

```text
TP3 mode=UINT8  op=ADD case=1 A=FA B=0A result=04 flags=01 OVERFLOW  pass=YES
```

5. Fotografe a placa com LED0 e LED1 ligados e salve:

- `evidencias/hardware/leds_overflow.jpg`

6. Pressione reset. Depois pressione BTN0 duas vezes e BTN2 uma vez para chegar a `mode=Q3.4 op=ADD case=1`, saturacao em ponto fixo:

```text
TP3 mode=Q3.4   op=ADD case=1 A=78 B=10 result=7F flags=09 OVF+SAT   pass=YES
```

7. Fotografe a placa com LED1 ligado e salve:

- `evidencias/hardware/leds_saturacao.jpg`

8. Salve uma captura do terminal mostrando as linhas UART como:

- `evidencias/hardware/serial_uart_resultados.png`

## 7. Checklist antes do ZIP manual

- `./sim/run_all.sh` termina com `All simulations completed.`
- `relatorio/relatorio_DR3_TP3.pdf` existe.
- As quatro imagens GTKWave foram salvas em `evidencias/waveforms/`.
- As tres capturas Gowin e o relatorio de recursos foram salvos em `evidencias/gowin/`.
- As fotos/captura serial foram salvas em `evidencias/hardware/`.
- O ZIP final deve seguir o nome `nome_sobrenome_DR3_TP3.zip`.
