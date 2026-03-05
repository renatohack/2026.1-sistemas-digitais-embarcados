# Relatorio Tecnico - DR1 TP2 (Verilog/FPGA)

Aluno: _preencher_nome_completo_  
Disciplina: Sistemas Embarcados / Verilog FPGA  
Placa-alvo: Tang Nano 9K (GW1NR-LV9QN88PC6/I5)  
Ferramenta: Gowin EDA V1.9.12.01 (64-bit)

## 1) Niveis logicos e sinais digitais

Em FPGA, o valor logico (`0` ou `1`) e representado por uma faixa de tensao eletrica em cada pino de I/O.  
Neste projeto na Tang Nano 9K foram usados dois padroes de I/O:

- `LVCMOS18` (LEDs e botoes onboard): `0` proximo de 0 V e `1` proximo de 1.8 V
- `LVCMOS33` (duas entradas extras em pinos de expansao): `0` proximo de 0 V e `1` proximo de 3.3 V

Na pratica, a FPGA nao interpreta apenas valores exatos (como 0.000 V, 1.800 V ou 3.300 V), e sim faixas validas para `LOW` e `HIGH` definidas pelo padrao eletrico do banco.

## 2) Convencao logica adotada

Convencao usada no TP:

- Switch pressionado -> `1` logico
- Switch solto -> `0` logico
- LED aceso -> `1` logico
- LED apagado -> `0` logico

Tabela de convencao:

| Sinal | Estado fisico | Valor logico |
|---|---|---|
| SW1 | pressionado / solto | 1 / 0 |
| SW2 | pressionado / solto | 1 / 0 |
| SW3 | pressionado / solto | 1 / 0 |
| SW4 | pressionado / solto | 1 / 0 |
| LED1 | aceso / apagado | 1 / 0 |
| LED2 | aceso / apagado | 1 / 0 |
| LED3 | aceso / apagado | 1 / 0 |
| LED4 | aceso / apagado | 1 / 0 |

Observacao de hardware (Tang Nano 9K): os LEDs onboard e os botoes onboard sao ativos em nivel baixo. Nesta entrega, a convencao logica do enunciado foi mantida na simulacao e no relatorio (`ativo = 1`).

## 3) Criacao do projeto no Gowin IDE

Projeto criado:

- Nome do projeto: `tp2_tang_nano_9k`
- Dispositivo selecionado: `GW1NR-LV9QN88PC6/I5`

Estrutura inicial de arquivos/pastas (padrao da IDE):

- `tp2_tang_nano_9k.gprj`
- `src/` (fontes do usuario)
- `impl/` (arquivos gerados de sintese e PnR)

## 4) Criacao do arquivo top.v no assistente da IDE

Passos executados na IDE:

1. `File > New File...`
2. Selecionar `Verilog File`
3. Nomear como `top.v`
4. Manter `Add to current project`
5. Confirmar em `OK`

## 5) Modulo Top com interface exigida

Interface implementada em `top.v`:

Entradas:

- `i_Switch_1`
- `i_Switch_2`
- `i_Switch_3`
- `i_Switch_4`

Saidas:

- `o_LED_1`
- `o_LED_2`
- `o_LED_3`
- `o_LED_4`

## 6) Wiring direto por continuous assignment

Ligacoes diretas implementadas:

- `o_LED_2 = i_Switch_2`
- `o_LED_3 = i_Switch_3`
- `o_LED_4 = i_Switch_4`

Explicacao (ate 5 linhas):

Em Verilog concorrente, `assign` descreve conexoes de hardware ativas em paralelo, nao uma sequencia de instrucoes como em software. Cada atribuicao vira logica combinacional/fio interno no netlist da FPGA. Assim, mudando a entrada, a saida correspondente muda automaticamente conforme o atraso de propagacao do circuito.

## 7) Modulo combinacional Logic_Block

Arquivo `logic_block.v` criado com:

- Entradas: `A`, `B`, `C`
- Saida: `F`
- Funcao: `F = (A & B) | (~C)`
- Implementacao somente com operadores combinacionais e `assign`

## 8) Integracao do Logic_Block ao Top

Conexoes implementadas:

- `A = i_Switch_1`
- `B = i_Switch_2`
- `C = i_Switch_3`
- `o_LED_1 = F`

LED mantido em conexao direta com switch:

- `o_LED_4 = i_Switch_4`

## 9) Testbench funcional (6 combinacoes exigidas)

Arquivo de teste: `top_tb.v`

Combinacoes aplicadas (na ordem do enunciado):

1. `0000`
2. `0101`
3. `1010`
4. `1100`
5. `1110`
6. `1001`

## 10) Tabela de simulacao funcional

Logica implementada no Top:

- `LED1 = (SW1 & SW2) | (~SW3)`
- `LED2 = SW2`
- `LED3 = SW3`
- `LED4 = SW4`

Tabela de resultados:

| Caso | SW1 | SW2 | SW3 | SW4 | LED1 | LED2 | LED3 | LED4 |
|---|---:|---:|---:|---:|---:|---:|---:|---:|
| 1 | 0 | 0 | 0 | 0 | 1 | 0 | 0 | 0 |
| 2 | 0 | 1 | 0 | 1 | 1 | 1 | 0 | 1 |
| 3 | 1 | 0 | 1 | 0 | 0 | 0 | 1 | 0 |
| 4 | 1 | 1 | 0 | 0 | 1 | 1 | 0 | 0 |
| 5 | 1 | 1 | 1 | 0 | 1 | 1 | 1 | 0 |
| 6 | 1 | 0 | 0 | 1 | 1 | 0 | 0 | 1 |

Conclusao da simulacao:

- O comportamento observado/esperado e consistente com a logica implementada.

Evidencia de simulacao (inserir screenshot da waveform):

![Waveform dos 6 casos](./imgs/simulacao_waveform.png)

## 11) Constraints, sintese e place & route

Arquivo de constraints: `constraints.cst`

Tabela "Sinal logico -> Pino fisico":

| Sinal logico | Pino fisico |
|---|---:|
| i_Switch_1 | 3 |
| i_Switch_2 | 4 |
| i_Switch_3 | 17 |
| i_Switch_4 | 18 |
| o_LED_1 | 10 |
| o_LED_2 | 11 |
| o_LED_3 | 13 |
| o_LED_4 | 14 |

Observacao: na Tang Nano 9K, os pinos de LED foram mapeados para LEDs onboard oficiais (10, 11, 13, 14), enquanto `i_Switch_1` e `i_Switch_2` usam botoes onboard (3, 4). Como a placa nao possui 4 switches onboard, `i_Switch_3` e `i_Switch_4` foram mapeados para pinos de expansao (17, 18).

Status do fluxo:

- Projeto preparado para `Synthesize` e `Place & Route` no Gowin IDE
- Registros esperados no processo: icones de sucesso em `Synthesize` e `Place & Route`

Evidencia de sintese (inserir screenshot de sucesso):

![Sintese concluida](./imgs/sintese_ok.png)

Evidencia de place & route (inserir screenshot de sucesso):

![Place and Route concluido](./imgs/pnr_ok.png)

## 12) Programacao na placa (Download to SRAM) e validacao fisica

Como o ambiente informado nao possui hardware disponivel (sem acesso a switches/LEDs fisicos), esta etapa fica registrada como **nao executada** neste TP por limitacao de bancada.

Para execucao futura, usar no Gowin Programmer:

- Operacao: `Download to SRAM`
- Executar os 6 casos da tabela de simulacao
- Registrar foto/video da placa para cada caso

Observacao para teste fisico na 9K: como recursos onboard sao ativos em nivel baixo, sera necessario considerar a polaridade inversa na interpretacao ou ajustar o codigo para inversao na camada de I/O.

Conclusao esperada quando houver hardware:

- O comportamento fisico deve reproduzir a tabela de simulacao funcional.

## 13) Arquivos entregues

- `top.v`
- `logic_block.v`
- `top_tb.v`
- `constraints.cst`
- `guia_gowin_click_a_clique.md`
- `relatorio_tecnico_tp2.md`

## 14) Referencias tecnicas

- Gowin Software User Guide (SUG100): https://cdn.gowinsemi.com.cn/SUG100E.pdf
- Gowin Software Quick Start Guide (SUG918): https://cdn.gowinsemi.com.cn/SUG918E.pdf
- Tang Nano 9K wiki oficial: https://wiki.sipeed.com/hardware/en/tang/Tang-Nano-9K/Nano-9K.html
