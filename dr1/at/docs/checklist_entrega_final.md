# Checklist Final de Entrega

## Estado atual

O projeto ja esta funcional em nivel de:

- modelagem logica
- RTL em Verilog
- testbench
- simulacao
- integracao com a Tang Nano 9K
- montagem no protoboard
- validacao fisica na placa

O que falta agora para fechar a entrega em 100% e gerar o relatorio final e:

- registrar as evidencias
- sintetizar e gerar o bitstream final no Gowin
- gravar e registrar a demonstracao final
- montar o PDF
- compactar tudo em um `.zip`


## Pastas criadas para organizar as evidencias

Use exatamente estas pastas:

- `evidencias/01_simulacao`
- `evidencias/02_gowin`
- `evidencias/02_gowin/bitstream`
- `evidencias/03_hardware`
- `evidencias/04_video`
- `entrega`


## Checklist

### 1. Regenerar as simulacoes finais

- [ ] Executar a simulacao completa uma ultima vez

Comando:

```bash
make clean && make sim
```

Arquivos que devem existir ao final:

- `sim/fst/access_control.fst`
- `sim/fst/access_control_tang_nano_9k_top.fst`
- `sim/gtkwave/access_control.gtkw`
- `sim/gtkwave/access_control_tang_nano_9k_top.gtkw`

Se aparecer:

- `SIMULACAO_OK`
- `SIMULACAO_FPGA_OK`

entao esta validado.


### 2. Gerar as evidencias de simulacao no GTKWave

- [ ] Abrir a simulacao principal no GTKWave

Comando:

```bash
make wave
```

- [ ] Opcionalmente abrir a simulacao da placa com os botoes toggle

Comando:

```bash
make wave-board
```

Como salvar os prints:

- neste ambiente nao apareceu ferramenta CLI de screenshot instalada
- entao abra a ferramenta grafica de captura do seu sistema e salve manualmente nos caminhos abaixo

Capturas obrigatorias para o relatorio:

- [ ] `evidencias/01_simulacao/01_codigo_correto.png`
  Mostre a validacao com `1011`, o pulso de confirmacao, `led_authorized` ativo e `led_denied` inativo.

- [ ] `evidencias/01_simulacao/02_codigo_incorreto.png`
  Mostre um codigo errado, o pulso de confirmacao, `led_denied` ativo e `led_authorized` inativo.

- [ ] `evidencias/01_simulacao/03_contador_tentativas.png`
  Mostre pelo menos 3 tentativas sucessivas e a mudanca de `led_count[2:0]`.
  O contador e binario:
  1 tentativa = `001`
  2 tentativas = `010`
  3 tentativas = `011`
  4 tentativas = `100`

- [ ] `evidencias/01_simulacao/04_reset_sistema.png`
  Mostre o contador diferente de zero antes do reset e zerado depois do reset.

Captura recomendada para explicar a adaptacao dos botoes em modo toggle:

- [ ] `evidencias/01_simulacao/05_toggle_dos_bits_na_placa.png`
  Abra com `make wave-board` e mostre `code_led[3:0]` ou `code_state[3:0]` mudando com toques curtos nos botoes.


### 3. Rodar o fluxo final no Gowin

- [ ] Abrir o projeto do Gowin

Arquivo para abrir:

- `gowin/access_control_tang_nano_9k.gprj`

- [ ] Confirmar o top-level

Ele deve estar como:

- `access_control_tang_nano_9k_top`

- [ ] Rodar `Synthesis`

Evidencia a salvar:

- `evidencias/02_gowin/01_synthesis_ok.png`

O print deve mostrar a sintese concluida com sucesso.

- [ ] Rodar `Place & Route`

Evidencia a salvar:

- `evidencias/02_gowin/02_place_route_ok.png`

O print deve mostrar que o mapeamento e roteamento terminaram com sucesso.

- [ ] Rodar `Generate Bitstream`

Evidencia a salvar:

- `evidencias/02_gowin/03_bitstream_ok.png`

O print deve mostrar a geracao final do arquivo da FPGA.

- [ ] Copiar o bitstream gerado para a pasta de evidencias

Procure no output do Gowin o arquivo com nome base:

- `access_control_tang_nano_9k`

Copie o que for gerado com esse nome base, normalmente `.fs` e/ou `.bin`, para:

- `evidencias/02_gowin/bitstream/`

Se houver mais de um arquivo, copie todos os relacionados ao bitstream.


### 4. Programar a placa e registrar a programacao

- [ ] Abrir o programador do Gowin
- [ ] Carregar o bitstream gerado
- [ ] Gravar a Tang Nano 9K

Evidencia a salvar:

- `evidencias/02_gowin/04_programacao_ok.png`

O print deve mostrar a programacao concluida com sucesso.


### 5. Gerar as evidencias fisicas do hardware

Antes das fotos:

- confira se a placa esta com o bitstream final
- confira se os 4 LEDs externos dos bits estao funcionando
- confira se os LEDs onboard de status e contador estao funcionando

Fotos obrigatorias recomendadas para o relatorio:

- [ ] `evidencias/03_hardware/01_montagem_geral.jpg`
  Foto aberta mostrando Tang Nano 9K, protoboard, botoes e LEDs.

- [ ] `evidencias/03_hardware/02_codigo_correto_1011.jpg`
  Procedimento:
  1. aperte `S2`
  2. toque no bit 3
  3. toque no bit 1
  4. toque no bit 0
  5. nao toque no bit 2
  6. aperte `S1`
  Tire a foto mostrando os LEDs externos indicando `1011` e o LED onboard de acesso autorizado.

- [ ] `evidencias/03_hardware/03_codigo_incorreto.jpg`
  Procedimento:
  1. aperte `S2`
  2. monte um codigo errado, por exemplo `0000` ou `1111`
  3. aperte `S1`
  Tire a foto mostrando o LED onboard de acesso negado.

- [ ] `evidencias/03_hardware/04_contador_apos_3_tentativas.jpg`
  Procedimento:
  1. aperte `S2`
  2. faca 3 validacoes seguidas com qualquer codigo
  3. tire a foto mostrando os LEDs `LED3`, `LED4` e `LED5` onboard representando o contador.
  Para 3 tentativas, o esperado e `011`, ou seja:
  - bit 0 aceso
  - bit 1 aceso
  - bit 2 apagado

- [ ] `evidencias/03_hardware/05_reset_sistema.jpg`
  Procedimento:
  1. deixe o contador diferente de zero
  2. aperte `S2`
  3. tire a foto mostrando os LEDs de status apagados e o contador zerado.

Observacao:

- se preferir, essas fotos podem ser quadros extraidos do video, mas fotos separadas costumam deixar o relatorio mais limpo


### 6. Gravar o video demonstrativo

- [ ] Gravar um video local da demonstracao

Salve o arquivo bruto em:

- `evidencias/04_video/access_control_tang_nano_9k_demo.mp4`

O video deve mostrar:

- funcionamento do sistema
- interacao com os botoes
- resposta observada nos LEDs
- idealmente sua webcam ligada, porque o enunciado pede defesa em video

Roteiro minimo sugerido:

1. mostrar rapidamente a Tang Nano 9K e o protoboard
2. explicar que a placa usada e a Tang Nano 9K e que os switches foram substituidos por botoes externos
3. mostrar o codigo correto `1011`
4. apertar `S1` e mostrar acesso autorizado
5. mostrar um codigo incorreto
6. apertar `S1` e mostrar acesso negado
7. mostrar o contador incrementando
8. apertar `S2` e mostrar o reset

Comportamento correto do contador no video:

- 1 tentativa = `001`
- 2 tentativas = `010`
- 3 tentativas = `011`
- 4 tentativas = `100`

- [ ] Subir o video para YouTube ou Google Drive

Requisitos do link:

- nao listado
- com permissao de visualizacao liberada

- [ ] Salvar o link do video em um arquivo texto

Crie:

- `evidencias/04_video/link_video.txt`

Coloque dentro apenas o link final do video.


### 7. Montar o relatorio final em PDF

- [ ] Gerar o PDF final

Salvar em:

- `entrega/nome_sobrenome_DR1_AT.PDF`

O PDF deve incluir:

- descricao do sistema
- arquitetura do circuito
- tabela verdade
- expressao booleana
- simplificacao
- decisoes de projeto
- interpretacao das formas de onda
- evidencias de hardware
- observacao de que a placa usada foi a Tang Nano 9K, com aprovacao do professor
- observacao de que os switches foram substituidos por botoes externos

Arquivos que voce deve aproveitar no relatorio:

- `docs/modelagem_logica.md`
- `docs/simulacao.md`
- `docs/fpga_tang_nano_9k.md`
- `docs/guia_montagem_protoboard_tang_nano_9k.txt`
- `evidencias/01_simulacao/*.png`
- `evidencias/03_hardware/*`
- `evidencias/04_video/link_video.txt`


### 8. Montar o .ZIP final

- [ ] Gerar o arquivo `.zip` final

Nome do arquivo:

- `entrega/nome_sobrenome_DR1_AT.zip`

Conteudo recomendado do zip:

- `rtl/`
- `tb/`
- `gowin/`
- `docs/`
- `sim/`
- `evidencias/`
- `README.md`
- `Makefile`
- `entrega/nome_sobrenome_DR1_AT.PDF`

Comandos sugeridos:

```bash
mkdir -p entrega/pacote_final
cp -r rtl tb gowin docs sim evidencias entrega/pacote_final/
cp README.md Makefile entrega/pacote_final/
cp entrega/nome_sobrenome_DR1_AT.PDF entrega/pacote_final/
cd entrega/pacote_final && zip -r ../nome_sobrenome_DR1_AT.zip .
```

Observacoes:

- nao inclua a pasta `build/`
- se o arquivo de video `.mp4` ficar muito grande, voce pode deixar no projeto apenas o `link_video.txt` e usar o link no PDF


## Checklist curtissima

Se quiser uma versao ultra curta, o que falta e:

- [ ] prints do GTKWave
- [ ] sintese no Gowin
- [ ] place and route no Gowin
- [ ] bitstream final
- [ ] programacao da placa
- [ ] fotos do hardware funcionando
- [ ] video demonstrativo com link publico por URL
- [ ] PDF final
- [ ] ZIP final


## Observacao importante sobre as waveforms

Voce nao precisa gerar sinais "ao vivo" dentro do GTKWave.

O GTKWave apenas mostra os sinais que ja foram dumpados pela simulacao nos arquivos
`.vcd` e `.fst`.

Entao:

- `make wave` abre a waveform do testbench principal
- `make wave-board` abre a waveform do testbench da placa

Os cenarios que voce vai fotografar ja estao dentro dessas simulacoes.

Ou seja, basta:

1. executar `make sim`
2. abrir `make wave` ou `make wave-board`
3. navegar ate o trecho desejado
4. tirar o print da tela
