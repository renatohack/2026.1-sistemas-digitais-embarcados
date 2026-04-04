# Roteiro de Uso do GTKWave

## O que o GTKWave faz

O GTKWave nao gera sinais novos.

Ele apenas mostra os sinais que ja foram gravados pela simulacao.

Entao o fluxo e sempre:

1. rodar a simulacao
2. abrir a waveform
3. navegar na linha do tempo
4. tirar o print


## Parte 1: simulacao principal

### 1. Gerar a simulacao

No terminal:

```bash
make sim
```

### 2. Abrir o GTKWave da simulacao principal

No terminal:

```bash
make wave
```

### 3. O que voce vai ver carregado

O layout ja abre com estes sinais:

- `tb_access_control.clk`
- `tb_access_control.btn_reset`
- `tb_access_control.btn_confirm`
- `tb_access_control.code_btn[3:0]`
- `tb_access_control.dut.code_sync[3:0]`
- `tb_access_control.dut.code_valid`
- `tb_access_control.led_attempt`
- `tb_access_control.led_authorized`
- `tb_access_control.led_denied`
- `tb_access_control.led_count[2:0]`
- `tb_access_control.dut.confirm_pulse`
- `tb_access_control.dut.attempt_count[2:0]`

### 4. Como navegar sem complicacao

- a parte da esquerda mostra os nomes dos sinais
- a parte da direita mostra as formas de onda
- o tempo corre da esquerda para a direita
- use a barra horizontal de baixo para andar na linha do tempo
- use a roda do mouse sobre a waveform para aproximar ou afastar, se o seu ambiente permitir
- se ficar muito longe, use os botoes de zoom do GTKWave ate conseguir ver os pulsos com clareza

Regra pratica:

- comece vendo a waveform inteira
- depois aproxime cada trecho que interessa

### 5. Ordem dos cenarios na waveform principal

Os cenarios aparecem nesta ordem, da esquerda para a direita:

1. `reset_inicial`
2. `codigo_correto`
3. `codigo_incorreto`
4. `multiplas_1`
5. `multiplas_2`
6. `reset_final`

Entao voce nao precisa procurar aleatoriamente. Basta caminhar da esquerda para a direita.


## Prints da simulacao principal

### Print 1: codigo correto

Salvar em:

- `evidencias/01_simulacao/01_codigo_correto.png`

O que mostrar:

- `code_btn[3:0]` ou `dut.code_sync[3:0]` com `1011`
- pulso em `btn_confirm`
- `dut.code_valid = 1`
- `led_authorized = 1`
- `led_denied = 0`

Como reconhecer o trecho:

- e o primeiro pulso de `btn_confirm` depois do `reset_inicial`


### Print 2: codigo incorreto

Salvar em:

- `evidencias/01_simulacao/02_codigo_incorreto.png`

O que mostrar:

- codigo diferente de `1011`
- pulso em `btn_confirm`
- `dut.code_valid = 0`
- `led_denied = 1`
- `led_authorized = 0`

Como reconhecer o trecho:

- e o segundo pulso de `btn_confirm`


### Print 3: contador de tentativas

Salvar em:

- `evidencias/01_simulacao/03_contador_tentativas.png`

O que mostrar:

- pelo menos 3 pulsos de `btn_confirm`
- a evolucao de `led_count[2:0]` ou `dut.attempt_count[2:0]`

Valores esperados:

- 1 tentativa = `001`
- 2 tentativas = `010`
- 3 tentativas = `011`
- 4 tentativas = `100`

Melhor trecho:

- pegue do primeiro ate o quarto pulso de `btn_confirm`


### Print 4: reset do sistema

Salvar em:

- `evidencias/01_simulacao/04_reset_sistema.png`

O que mostrar:

- `led_count[2:0]` diferente de zero antes do reset
- `btn_reset` ativo
- `led_count[2:0] = 000` depois do reset
- `led_authorized = 0`
- `led_denied = 0`

Como reconhecer o trecho:

- e o ultimo evento da waveform


## Parte 2: simulacao da placa

### 1. Abrir o GTKWave da placa

No terminal:

```bash
make wave-board
```

### 2. O que vai aparecer carregado

O layout ja abre com estes sinais:

- `tb_access_control_tang_nano_9k_top.sys_clk`
- `tb_access_control_tang_nano_9k_top.btn_reset_n`
- `tb_access_control_tang_nano_9k_top.btn_confirm_n`
- `tb_access_control_tang_nano_9k_top.code_btn[3:0]`
- `tb_access_control_tang_nano_9k_top.dut.btn_reset_db`
- `tb_access_control_tang_nano_9k_top.dut.btn_confirm_db`
- `tb_access_control_tang_nano_9k_top.dut.code_state[3:0]`
- `tb_access_control_tang_nano_9k_top.code_led[3:0]`
- `tb_access_control_tang_nano_9k_top.dut.access_control_inst.code_sync[3:0]`
- `tb_access_control_tang_nano_9k_top.dut.access_control_inst.code_valid`
- `tb_access_control_tang_nano_9k_top.led[5:0]`
- `tb_access_control_tang_nano_9k_top.dut.access_control_inst.led_count[2:0]`

### 3. Ordem dos cenarios na waveform da placa

Os eventos aparecem nesta ordem:

1. `reset_inicial_fpga`
2. `toggle_bit3_on`
3. `toggle_bit1_on`
4. `toggle_bit0_on`
5. `codigo_correto_fpga`
6. `toggle_bit0_off`
7. `codigo_incorreto_fpga`
8. `toggle_bit0_on_again`
9. `toggle_bit2_on`
10. `codigo_incorreto_fpga_2`
11. `reset_final_fpga`


## Print da placa com toggle

### Print 5: toggle dos bits

Salvar em:

- `evidencias/01_simulacao/05_toggle_dos_bits_na_placa.png`

O que mostrar:

- pulsos curtos em `code_btn[3:0]`
- mudanca persistente em `dut.code_state[3:0]`
- `code_led[3:0]` acompanhando o estado armazenado

Melhor trecho:

- pegue da regiao que vai de `toggle_bit3_on` ate `toggle_bit0_on`

Resultado esperado nesse trecho:

- depois do primeiro toque: `1000`
- depois do segundo toque: `1010`
- depois do terceiro toque: `1011`


## Dica pratica para nao se perder

Se voce nunca usou GTKWave, faca assim:

1. abra a waveform
2. primeiro olhe so `btn_confirm` e `btn_reset`
3. encontre os pulsos
4. depois olhe `code_sync` e `code_valid`
5. por fim olhe `led_authorized`, `led_denied` e `led_count`

Se for a waveform da placa:

1. olhe `code_btn`
2. depois `dut.code_state`
3. depois `code_led`
4. por fim `led[5:0]`


## Se algum sinal nao estiver visivel

No painel da esquerda:

1. encontre o sinal na arvore do modulo
2. clique duas vezes no nome dele
3. ele vai para a lista de sinais exibidos

Mas, em principio, os layouts `.gtkw` ja estao preparados para voce nao precisar fazer isso.
