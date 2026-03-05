# Guia Gowin V1.9.12.01 (64-bit) - Clique a Clique (TP2, Tang Nano 9K)

Este guia cobre **todas as etapas do TP2** no fluxo da Gowin, incluindo criacao de projeto, codigos, testbench, constraints, sintese e PnR.

## 0) Arquivos que voce ja tem prontos

Use estes arquivos na pasta do projeto:

- `top.v`
- `logic_block.v`
- `top_tb.v`
- `constraints.cst`

## 1) Criar projeto novo na Gowin

1. Abra o programa `Gowin FPGA Designer`.
2. Clique em `File > New Project...`.
3. Em `Project Name`, digite: `tp2_tang_nano_9k`.
4. Em `Project Location`, escolha uma pasta (ex.: `C:\fpga\tp2_tang_nano_9k`).
5. Clique `Next`.
6. Na tela do dispositivo, selecione:
- `Series`: `GW1NR`
- `Device`: `GW1NR-9C`
- `Package`: `QFN88P`
- `Speed`: `C6/I5`
- `Part Number`: `GW1NR-LV9QN88PC6/I5`
7. Clique `Next` e depois `Finish`.

## 2) Criar os arquivos Verilog dentro da IDE

### 2.1 Criar `top.v`

1. Clique `File > New File...`.
2. Selecione `Verilog File`.
3. Clique `OK`.
4. Cole o conteudo do arquivo `top.v`.
5. Clique `File > Save As...` e salve como `top.v`.

### 2.2 Criar `logic_block.v`

1. Clique `File > New File...`.
2. Selecione `Verilog File`.
3. Clique `OK`.
4. Cole o conteudo de `logic_block.v`.
5. Salve como `logic_block.v`.

### 2.3 Criar `top_tb.v` (testbench)

1. Clique `File > New File...`.
2. Selecione `Verilog File`.
3. Clique `OK`.
4. Cole o conteudo de `top_tb.v`.
5. Salve como `top_tb.v`.

## 3) Adicionar/organizar arquivos no projeto

1. No painel `Hierarchy`, clique com botao direito no nome do projeto.
2. Clique `Add Existing File...`.
3. Adicione `top.v`, `logic_block.v`, `top_tb.v` e `constraints.cst`.
4. No painel `Hierarchy`, clique com botao direito em `top.v`.
5. Clique `Set As Top Module`.
6. Verifique se o modulo topo ficou como `Top`.

## 4) Conferencia rapida de compilacao RTL

1. Clique `Process` (painel lateral).
2. Clique com botao direito em `Synthesize`.
3. Clique `Run`.
4. Aguarde finalizar e confirme icone verde em `Synthesize`.

Se houver erro, normalmente e nome de modulo/porta diferente entre `Top` e testbench.

## 5) Simulacao funcional (itens 9 e 10 do enunciado)

O enunciado pede, como obrigatorio, executar a simulacao e registrar no relatorio uma tabela com valores de switches e LEDs, alem de confirmar se bate com o esperado.

### 5.1 Fluxo de simulacao (DSim Studio no VS Code)

1. Abra no VS Code a pasta do projeto: `tp2_tang_nano_9k`.
2. No painel `DSIM STUDIO`, abra o projeto `tp2_tang_nano_9k.dpf`.
3. Em `LIBRARY CONFIGURATION` (library `work`), clique `+` e adicione:
- `src/logic_block.v`
- `src/top.v`
- `src/top_tb.v`
4. Em `SIMULATION CONFIGURATION`, clique `+` para criar uma simulacao.
5. Em `Simulation Name`, use `top_tb`.
6. Em `Options`, preencha:
```txt
-top work.Top_tb
```
7. Clique `Save`.
8. Rode `Compile Project` no DSIM Studio (ou botao play da library `work`).
9. Rode `Run` na simulacao `top_tb`.

### 5.2 O que registrar no relatorio (obrigatorio)

1. Copie o resultado do console com os 6 casos do testbench.
2. Monte a tabela "Switches aplicados x LEDs observados".
3. Escreva a conclusao explicita: "o comportamento observado corresponde ao esperado".
4. Se precisar recuperar depois, use o log local: `tp2_tang_nano_9k/dsim.log`.

Resultado esperado para conferencia:

- `0000 -> 1000`
- `0101 -> 1101`
- `1010 -> 0010`
- `1100 -> 1100`
- `1110 -> 1110`
- `1001 -> 1001`

### 5.3 Waveform (opcional)

A waveform ajuda na visualizacao, mas nao e exigencia explicita do enunciado.

Observacao importante: no fluxo local, o painel `JOBS` pode ficar vazio (ele e mais usado no fluxo cloud). Isso nao impede a entrega.

Se sua instalacao gerar arquivo de ondas, abra esse arquivo no visualizador do DSim e adicione `i_Switch_1..4` e `o_LED_1..4`.

### 5.4 Diagnostico rapido

1. Se abrir browser pedindo download/licenca, feche e use o DSim local no VS Code.
2. Se aparecer erro de top:
- use `-top work.Top_tb` (nao use nome de arquivo em `-top`);
- confirme que `src/top_tb.v` foi adicionado;
- compile antes de rodar.

## 6) Criar constraints no FloorPlanner (como o enunciado pede)

`Constraints` definem em qual pino fisico da FPGA cada sinal logico do seu codigo sera conectado.

`FloorPlanner` e a ferramenta grafica da Gowin para fazer esse mapeamento. Ao salvar no FloorPlanner, a IDE gera/atualiza o arquivo `.cst` automaticamente.

Conclusao pratica: para este TP, prefira gerar/editar o `.cst` pelo FloorPlanner (nao na mao).

### 6.1 Abrir FloorPlanner

1. Na Gowin, no painel `Process`, clique em `FloorPlanner` (duplo clique).
2. Se solicitado, confirme abertura apos sintese.

### 6.2 Criar/editar constraints

1. No FloorPlanner, abra a janela `I/O Constraints`.
- Se nao aparecer: `View > I/O Constraints`.
2. Na tabela de portas, localize cada sinal:
- `i_Switch_1`, `i_Switch_2`, `i_Switch_3`, `i_Switch_4`
- `o_LED_1`, `o_LED_2`, `o_LED_3`, `o_LED_4`
3. Atribua os pinos (arrastando para `Package View` ou editando a coluna `Location`):
- `i_Switch_1 -> 3`
- `i_Switch_2 -> 4`
- `i_Switch_3 -> 17`
- `i_Switch_4 -> 18`
- `o_LED_1 -> 10`
- `o_LED_2 -> 11`
- `o_LED_3 -> 13`
- `o_LED_4 -> 14`
4. Clique `Save` no FloorPlanner.
5. Confirme que o arquivo `.cst` foi salvo no projeto.

Observacoes de hardware da 9K:

- A placa tem 2 botoes onboard (nao 4).
- `i_Switch_1` e `i_Switch_2` usam botoes onboard; `i_Switch_3` e `i_Switch_4` estao em pinos de expansao.
- LEDs e botoes onboard da 9K sao ativos em nivel baixo (logica invertida no nivel eletrico).

## 7) Sintese e Place & Route

1. Volte para a janela principal da Gowin.
2. Em `Process`, clique com botao direito em `Synthesize > Run`.
3. Depois clique com botao direito em `Place & Route > Run`.
4. Verifique icone verde em ambos.
5. Abra os relatorios (`*_syn.rpt.html`, `*_pnr.rpt.html`) para screenshot de evidencia.

Observacao: mesmo sem placa conectada, `Synthesize` e `Place & Route` continuam uteis e fazem parte do fluxo exigido. Eles validam que o projeto fecha no dispositivo e geram os artefatos de implementacao.

## 8) Programacao SRAM (opcional no seu caso, sem hardware)

Como voce informou que nao tem hardware fisico conectado, esta etapa fica apenas como procedimento:

1. Clique `Tools > Programmer`.
2. Selecione o dispositivo detectado.
3. Em operacao, escolha `Download to SRAM`.
4. Clique `Program/Start`.
5. Teste os 6 casos na placa e registre foto/video.

## 9) Tabela esperada para conferir simulacao

| SW1 | SW2 | SW3 | SW4 | LED1 | LED2 | LED3 | LED4 |
|---:|---:|---:|---:|---:|---:|---:|---:|
| 0 | 0 | 0 | 0 | 1 | 0 | 0 | 0 |
| 0 | 1 | 0 | 1 | 1 | 1 | 0 | 1 |
| 1 | 0 | 1 | 0 | 0 | 0 | 1 | 0 |
| 1 | 1 | 0 | 0 | 1 | 1 | 0 | 0 |
| 1 | 1 | 1 | 0 | 1 | 1 | 1 | 0 |
| 1 | 0 | 0 | 1 | 1 | 0 | 0 | 1 |

## 10) Evidencias (prints) - exatamente o que capturar

Salve os prints na pasta `imgs/` com os nomes abaixo para o relatorio reconhecer automaticamente.

1. **Print da simulacao (obrigatorio)**  
Etapa do guia: secao **5.2**, apos executar a simulacao.  
O que deve aparecer no print:
- console com os 6 casos do testbench (`SW1..SW4` e `LED1..LED4`);
- evidencia de que a simulacao executou ate o fim.  
Nome do arquivo: `imgs/simulacao_console.png`

2. **Print da waveform (opcional)**  
Etapa do guia: secao **5.3**, se voce optar por abrir ondas.  
O que deve aparecer no print:
- sinais `i_Switch_1..4` e `o_LED_1..4` na waveform;
- transicoes dos 6 casos.  
Nome sugerido: `imgs/simulacao_waveform.png`

3. **Print da sintese concluida**  
Etapa do guia: secao **7**, apos `Synthesize > Run`.  
O que deve aparecer no print:
- painel `Process`
- `Synthesize` com status de sucesso (icone verde/check)
- de preferencia com timestamp/log visivel  
Nome do arquivo: `imgs/sintese_ok.png`

4. **Print do Place & Route concluido**  
Etapa do guia: secao **7**, apos `Place & Route > Run`.  
O que deve aparecer no print:
- painel `Process`
- `Place & Route` com status de sucesso (icone verde/check)  
Nome do arquivo: `imgs/pnr_ok.png`

5. **(Opcional) Prints de teste fisico**  
Etapa do guia: secao **8**, somente se programar placa real.  
O que deve aparecer no print:
- placa ligada
- estado dos LEDs correspondente ao caso testado  
Nomes sugeridos:
- `imgs/teste_fisico_caso1.png`
- `imgs/teste_fisico_caso2.png`
- `imgs/teste_fisico_caso3.png`
- `imgs/teste_fisico_caso4.png`
- `imgs/teste_fisico_caso5.png`
- `imgs/teste_fisico_caso6.png`

## 11) Checklist final para entrega

1. Confirmar no projeto:
- `top.v`
- `logic_block.v`
- `top_tb.v`
- `constraints.cst`
2. Salvar screenshot de:
- simulacao (console)
- simulacao (waveform, opcional)
- sintese concluida
- place & route concluido
3. Atualizar o relatorio (`relatorio_tecnico_tp2.md`) com as imagens.
4. Compactar tudo em `.zip` com o nome exigido pelo professor.

## 12) Referencias usadas para este guia

- Gowin Software User Guide (SUG100): https://cdn.gowinsemi.com.cn/SUG100E.pdf
- Gowin Software Quick Start Guide (SUG918): https://cdn.gowinsemi.com.cn/SUG918E.pdf
- Tang Nano 9K wiki: https://wiki.sipeed.com/hardware/en/tang/Tang-Nano-9K/Nano-9K.html
