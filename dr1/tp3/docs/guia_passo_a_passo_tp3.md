# Guia Passo a Passo - DR1 TP3 (detalhado)

## 1. O que ja esta pronto neste diretorio
Estrutura criada para voce:

- `src/comb_logic.v`
- `src/mux2to1.v`
- `src/reg1.v`
- `src/counter2bit.v`
- `src/top.v`
- `tb/tb_comb_logic.v`
- `tb/tb_mux2to1.v`
- `tb/tb_reg1.v`
- `tb/tb_counter2bit.v`
- `docs/relatorio_tp3_template.md`
- `docs/guia_passo_a_passo_tp3.md`
- `gowin/tang_nano_9k_constraints_template.cst`

## 2. Convencao deste guia
Sempre que aparecer:

- `[ACAO MANUAL SUA]`: voce precisa agir.
- `Entrada esperada`: o que voce digita/clica/seleciona.
- `Saida esperada`: o que deve aparecer se deu certo.

## 3. Pre-requisitos (antes de abrir o projeto)

### Passo 3.1 - Instalar Gowin IDE
- [ACAO MANUAL SUA]
- Entrada esperada: baixar instalador oficial da Gowin IDE e executar.
- Saida esperada: atalho do Gowin IDE disponivel no sistema.

### Passo 3.2 - Driver USB/JTAG da placa
- [ACAO MANUAL SUA]
- Entrada esperada: instalar driver USB da Tang Nano 9K (normalmente Gowin USB Cable).
- Saida esperada: ao conectar a placa, o sistema reconhece o dispositivo USB sem erro.

### Passo 3.3 - Cabo e alimentacao
- [ACAO MANUAL SUA]
- Entrada esperada: conectar cabo USB de dados (nao apenas cabo de carga) da placa ao computador.
- Saida esperada: LED de alimentacao da placa acende.

## 4. Ajuste obrigatorio no arquivo comb_logic.v

### Passo 4.1 - Abrir arquivo
- [ACAO MANUAL SUA]
- Entrada esperada: abrir `src/comb_logic.v` no editor.
- Saida esperada: encontrar a linha `assign F = C;`.

### Passo 4.2 - Substituir a expressao
- [ACAO MANUAL SUA]
- Entrada esperada: confirmar que a linha esta `assign F = C;` (ja ajustado neste projeto).
- Saida esperada: arquivo salvo sem erros de sintaxe.

### Passo 4.2.1 - Explicacao simples da expressao minimizada deste TP
- No enunciado, a funcao e `F(A,B,C) = Sm(1,3,5,7)`.
- Esses mintermos correspondem a `001`, `011`, `101`, `111`.
- Em todos eles, `C=1`.
- Logo, a forma minimizada e:

```text
F = C
```

### Passo 4.3 - Validar sintaxe visualmente
- [ACAO MANUAL SUA]
- Entrada esperada: conferir se:
  - toda linha termina com `;`
  - modulo fecha com `endmodule`
  - nomes de sinais batem (`A`, `B`, `C`, `F`)
- Saida esperada: sem erros visiveis.

## 5. Criar projeto no Gowin IDE (do zero)

### Passo 5.1 - Abrir Gowin
- [ACAO MANUAL SUA]
- Entrada esperada: iniciar aplicativo Gowin IDE.
- Saida esperada: janela principal aberta.

### Passo 5.2 - Novo projeto
- [ACAO MANUAL SUA]
- Entrada esperada:
  1. Menu `File` -> `New Project`.
  2. `Project Name`: `tp3_dr1`
  3. `Project Location`: selecione este diretorio do TP3.
  4. Clique em `Next`.
- Saida esperada: tela de selecao de dispositivo.

### Passo 5.3 - Selecionar dispositivo da placa
- [ACAO MANUAL SUA]
- Entrada esperada:
  1. Ler o modelo exato da sua Tang Nano 9K (caixa/manual/silkscreen).
  2. Selecionar no Gowin o mesmo device/package/speed.
- Saida esperada: dispositivo selecionado sem alerta de incompatibilidade.

### Passo 5.4 - Finalizar criacao
- [ACAO MANUAL SUA]
- Entrada esperada: `Finish`.
- Saida esperada: arvore do projeto aparece no painel lateral.

## 6. Adicionar arquivos fonte ao projeto

### Passo 6.1 - Adicionar modulos Verilog
- [ACAO MANUAL SUA]
- Entrada esperada:
  1. Botao direito em `Design` ou `src` no Gowin.
  2. `Add Files...`
  3. Selecionar:
     - `src/comb_logic.v`
     - `src/mux2to1.v`
     - `src/reg1.v`
     - `src/counter2bit.v`
     - `src/top.v`
- Saida esperada: todos os arquivos listados na arvore do projeto.

### Passo 6.2 - Definir top module
- [ACAO MANUAL SUA]
- Entrada esperada:
  1. Botao direito em `src/top.v`
  2. `Set as Top Module`
- Saida esperada: `top` marcado como modulo principal.

## 7. Check de sintaxe e sintese inicial

### Passo 7.1 - Rodar Synthesis
- [ACAO MANUAL SUA]
- Entrada esperada: clicar em `Run Synthesis`.
- Saida esperada: mensagem de sucesso no log (`Synthesis done` ou equivalente).

### Passo 7.2 - Se houver erro
- [ACAO MANUAL SUA]
- Entrada esperada: clicar no erro no log para abrir linha exata do arquivo.
- Saida esperada: cursor vai para linha com problema.
- Correcao tipica:
  - ponto e virgula faltando
  - nome de sinal digitado errado
  - modulo sem `endmodule`

## 8. Configurar pinos da Tang Nano 9K (constraints)

### Passo 8.1 - Abrir template
- [ACAO MANUAL SUA]
- Entrada esperada: abrir `gowin/tang_nano_9k_constraints_template.cst`.
- Saida esperada: visualizar placeholders `PIN_CLK`, `PIN_RESET`, `PIN_LED0`, `PIN_LED1`.

### Passo 8.2 - Descobrir pinos reais
- [ACAO MANUAL SUA]
- Entrada esperada: consultar pinout oficial da sua revisao da Tang Nano 9K.
- Saida esperada: tabela com pinos reais para clock, botao/reset, LED0, LED1.

### Passo 8.3 - Substituir placeholders
- [ACAO MANUAL SUA]
- Entrada esperada:
  - trocar `PIN_CLK`, `PIN_RESET`, `PIN_LED0`, `PIN_LED1` pelos pinos reais.
- Saida esperada: arquivo `.cst` sem placeholders.

### Passo 8.4 - Importar constraint no Gowin
- [ACAO MANUAL SUA]
- Entrada esperada:
  1. `Project` -> `Add Files...`
  2. selecionar o `.cst` editado.
- Saida esperada: `.cst` aparece na arvore do projeto.

## 9. Implementacao completa (Place & Route)

### Passo 9.1 - Rodar Place & Route
- [ACAO MANUAL SUA]
- Entrada esperada: `Run Place & Route`.
- Saida esperada: processo finaliza com sucesso.

### Passo 9.2 - Gerar bitstream
- [ACAO MANUAL SUA]
- Entrada esperada: `Generate Bitstream` (se nao for automatico).
- Saida esperada: arquivo de configuracao gerado (`.fs` ou formato equivalente da Gowin).

## 10. Programar a placa

### Passo 10.1 - Abrir Programmer
- [ACAO MANUAL SUA]
- Entrada esperada: `Tools` -> `Programmer`.
- Saida esperada: janela do programador aberta.

### Passo 10.2 - Detectar dispositivo
- [ACAO MANUAL SUA]
- Entrada esperada: clicar em detectar/scan dispositivo.
- Saida esperada: FPGA aparece na lista (sem erro de conexao).

### Passo 10.3 - Carregar bitstream
- [ACAO MANUAL SUA]
- Entrada esperada: selecionar arquivo gerado da etapa anterior.
- Saida esperada: arquivo carregado na lista de programacao.

### Passo 10.4 - Programar
- [ACAO MANUAL SUA]
- Entrada esperada: clicar em `Program/Download`.
- Saida esperada: status de sucesso (ex.: `Program Succeeded`).

## 11. Validacao fisica do contador (Item 12)

### Passo 11.1 - Observar LEDs
- [ACAO MANUAL SUA]
- Entrada esperada: olhar `led0` e `led1` na placa apos programacao.
- Saida esperada: sequencia binaria ciclica:
  - `00`
  - `01`
  - `10`
  - `11`
  - repete

### Passo 11.2 - Reset
- [ACAO MANUAL SUA]
- Entrada esperada: acionar sinal de reset (botao/entrada mapeada).
- Saida esperada: contador volta para `00`.

### Passo 11.3 - Evidencia
- [ACAO MANUAL SUA]
- Entrada esperada: gravar video curto (10-20s) ou tirar fotos da sequencia.
- Saida esperada: arquivos de evidencia salvos para anexar no relatorio/AVA.

## 12. Simulacao dos testbenches (para o relatorio)

Observacao: nesta maquina nao havia `iverilog` instalado. Se voce tiver `iverilog` no seu ambiente, use os comandos abaixo.

### Passo 12.1 - Simular Comb_Logic
- [ACAO MANUAL SUA]
- Entrada esperada:

```bash
iverilog -g2012 -o tb_comb_logic.out src/comb_logic.v tb/tb_comb_logic.v
vvp tb_comb_logic.out
```

- Saida esperada: tabela `A B C | F` com 8 linhas.

### Passo 12.2 - Simular Mux2to1
- [ACAO MANUAL SUA]
- Entrada esperada:

```bash
iverilog -g2012 -o tb_mux2to1.out src/mux2to1.v tb/tb_mux2to1.v
vvp tb_mux2to1.out
```

- Saida esperada: linhas no formato `D0=x D1=y S=z -> Y=w`.

### Passo 12.3 - Simular Reg1
- [ACAO MANUAL SUA]
- Entrada esperada:

```bash
iverilog -g2012 -o tb_reg1.out src/reg1.v tb/tb_reg1.v
vvp tb_reg1.out
```

- Saida esperada: monitor temporal mostrando comportamento no clock e reset.

### Passo 12.4 - Simular Counter2bit
- [ACAO MANUAL SUA]
- Entrada esperada:

```bash
iverilog -g2012 -o tb_counter2bit.out src/reg1.v src/counter2bit.v tb/tb_counter2bit.v
vvp tb_counter2bit.out
```

- Saida esperada: `Q1Q0` seguindo a contagem binaria e resetando quando `reset=1`.

## 13. Preencher relatorio tecnico

### Passo 13.1 - Abrir template
- [ACAO MANUAL SUA]
- Entrada esperada: abrir `docs/relatorio_tp3_template.md`.
- Saida esperada: documento com todas as secoes dos itens 1 a 12.

### Passo 13.2 - Preencher itens 1, 2 e 3
- [ACAO MANUAL SUA]
- Entrada esperada:
  - completar interpretacao da funcao,
  - tabela verdade,
  - SOP,
  - POS,
  - mapa de Karnaugh,
  - expressao minimizada.
- Saida esperada: secoes sem campos `[PREENCHER]`.

### Passo 13.3 - Preencher simulacao
- [ACAO MANUAL SUA]
- Entrada esperada: copiar resultados dos testbenches para as tabelas do relatorio.
- Saida esperada: relatorio com evidencias de validacao funcional.

### Passo 13.4 - Inserir evidencia da placa
- [ACAO MANUAL SUA]
- Entrada esperada: anexar referencias para foto/video da Tang Nano 9K funcionando.
- Saida esperada: item 12 completo.

## 14. Checklist final antes do ZIP

Confirme um por um:

- [ ] `src/comb_logic.v` preenchido com sua expressao minimizada.
- [ ] `src/mux2to1.v` presente.
- [ ] `src/reg1.v` presente.
- [ ] `src/counter2bit.v` presente.
- [ ] `src/top.v` presente.
- [ ] testbenches em `tb/` presentes.
- [ ] constraints `.cst` com pinos reais (sem placeholders).
- [ ] simulacao executada e registrada no relatorio.
- [ ] evidencia fisica gravada (foto/video).
- [ ] relatorio sem campos `[PREENCHER]`.

## 15. Gerar ZIP com nome exigido

### Passo 15.1 - Nome do arquivo
- [ACAO MANUAL SUA]
- Entrada esperada: definir nome no padrao:
  - `nome_sobrenome_DR1_TP3.zip`
- Saida esperada: arquivo zip com nome correto.

### Passo 15.2 - Comando sugerido no terminal
- [ACAO MANUAL SUA]
- Entrada esperada (rodar na pasta do TP3):

```bash
zip -r nome_sobrenome_DR1_TP3.zip src tb docs gowin
```

- Saida esperada: arquivo `.zip` criado sem erro.

### Passo 15.3 - Verificar conteudo do ZIP
- [ACAO MANUAL SUA]
- Entrada esperada:

```bash
unzip -l nome_sobrenome_DR1_TP3.zip
```

- Saida esperada: listar todos os arquivos do projeto.

## 16. Envio no AVA

### Passo 16.1 - Upload
- [ACAO MANUAL SUA]
- Entrada esperada: abrir atividade TP3 no AVA e anexar o ZIP.
- Saida esperada: status da submissao atualizado.

### Passo 16.2 - Confirmacao final
- [ACAO MANUAL SUA]
- Entrada esperada: verificar no AVA se o arquivo anexado e o nome estao corretos.
- Saida esperada: submissao confirmada.
