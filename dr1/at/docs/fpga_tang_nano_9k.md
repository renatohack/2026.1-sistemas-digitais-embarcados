# Integracao com a Tang Nano 9K

## Objetivo desta etapa

Esta etapa prepara o projeto para sintese, place-and-route e gravacao no Gowin, mantendo a adaptacao combinada:

- apenas os 4 botoes do codigo ficam no protoboard
- confirmacao e reset ficam em botoes onboard
- os LEDs de status principais ficam onboard
- 4 LEDs extras no protoboard mostram visualmente o estado dos bits do codigo

## Arquivos do Gowin

- `gowin/access_control_tang_nano_9k.gprj`: projeto para abrir diretamente no Gowin IDE
- `gowin/src/access_control_tang_nano_9k_top.v`: wrapper especifico da placa
- `gowin/src/access_control_tang_nano_9k.cst`: pinagem fisica
- `gowin/src/access_control_tang_nano_9k.sdc`: restricao de clock de 27 MHz
- `gowin/impl/project_process_config.json`: configuracao base do fluxo do Gowin

## Mapeamento adotado

### Recursos onboard

| Funcao logica | Recurso fisico | FPGA pin | Observacao |
|---|---|---:|---|
| `sys_clk` | clock onboard 27 MHz | 52 | banco 3.3 V |
| `btn_confirm_n` | botao onboard S1 | 3 | ativo em `0`, banco 1.8 V |
| `btn_reset_n` | botao onboard S2 | 4 | ativo em `0`, banco 1.8 V |
| `led[0]` | LED1 onboard | 10 | ativo em `0` |
| `led[1]` | LED2 onboard | 11 | ativo em `0` |
| `led[2]` | LED3 onboard | 13 | ativo em `0` |
| `led[3]` | LED4 onboard | 14 | ativo em `0` |
| `led[4]` | LED5 onboard | 15 | ativo em `0` |
| `led[5]` | LED6 onboard | 16 | ativo em `0` |

### Botoes externos do codigo

Os 4 botoes que substituem os switches foram mapeados para GPIOs livres de 3.3 V expostos no conector de expansao:

| Bit do codigo | Sinal | FPGA pin | Comportamento |
|---|---|---:|---|
| bit 0 | `code_btn[0]` | 25 | toque alterna o bit 0 |
| bit 1 | `code_btn[1]` | 26 | toque alterna o bit 1 |
| bit 2 | `code_btn[2]` | 27 | toque alterna o bit 2 |
| bit 3 | `code_btn[3]` | 28 | toque alterna o bit 3 |

### LEDs externos de visualizacao dos bits

| Bit exibido | Sinal | FPGA pin | Observacao |
|---|---|---:|---|
| bit 0 | `code_led[0]` | 29 | LED externo ativo em `1` |
| bit 1 | `code_led[1]` | 30 | LED externo ativo em `1` |
| bit 2 | `code_led[2]` | 33 | LED externo ativo em `1` |
| bit 3 | `code_led[3]` | 24 | LED externo ativo em `1` |

## Como montar os 4 botoes no protoboard

Cada botao externo deve ser ligado:

1. um terminal ao GPIO correspondente (`25`, `26`, `27` ou `28`)
2. o outro terminal a `3.3 V`

Os GPIOs do codigo foram configurados com `PULL_MODE=DOWN`, entao:

- botao solto = `0`
- botao pressionado = `1`

Na camada fisica, cada clique gera um pulso. O wrapper da Tang Nano 9K faz debounce, detecta a borda e alterna o bit correspondente.

Assim, para digitar o codigo `1011`:

1. toque no botao do bit `3`
2. toque no botao do bit `1`
3. toque no botao do bit `0`
4. nao toque no botao do bit `2`
5. aperte o botao onboard de confirmacao

## Relacao entre LEDs fisicos e LEDs do enunciado

| Enunciado | Recurso fisico na Tang Nano 9K |
|---|---|
| `LED0` acesso autorizado | LED1 onboard |
| `LED1` acesso negado | LED2 onboard |
| `LED2` tentativa registrada | LED3 onboard |
| `LED3` contador bit 0 | LED4 onboard |
| `LED4` contador bit 1 | LED5 onboard |
| `LED5` contador bit 2 | LED6 onboard |

## LEDs externos de apoio visual

Os LEDs externos do protoboard nao fazem parte do enunciado original. Eles foram adicionados apenas para mostrar o estado atual dos 4 bits armazenados em modo toggle:

- `code_led[0]`: bit 0
- `code_led[1]`: bit 1
- `code_led[2]`: bit 2
- `code_led[3]`: bit 3

## Observacoes de implementacao

- O wrapper `access_control_tang_nano_9k_top.v` faz a inversao dos botoes e LEDs onboard, porque esses recursos da placa sao ativos em nivel baixo.
- Os botoes onboard de confirmacao e reset passam por debounce antes de chegar ao modulo principal.
- Os 4 botoes externos do codigo tambem passam por debounce e sao convertidos para modo toggle no wrapper da placa.
- As saidas `code_led[3:0]` espelham diretamente o estado armazenado dos 4 bits e foram mapeadas para GPIOs livres da placa.
- O modulo principal `rtl/access_control.v` foi mantido generico; a dependencia da placa ficou isolada no wrapper do Gowin.

## Fontes usadas para a pinagem

- Sipeed Wiki da Tang Nano 9K
- Exemplo oficial de LED da Sipeed para Tang Nano 9K
- Exemplo oficial de UART da Sipeed para Tang Nano 9K
- Esquematico oficial da placa Tang Nano 9K

## Uso no Gowin

1. abra o arquivo `gowin/access_control_tang_nano_9k.gprj`
2. confirme que o top-level e `access_control_tang_nano_9k_top`
3. rode `Synthesis`, `Place & Route` e `Generate Bitstream`

Se o Gowin acusar restricao relacionada a pino de funcao dupla para o botao `S2` (pin 4), ajuste a opcao correspondente em `Project > Configuration > Dual Purpose Pin` e salve o projeto.
