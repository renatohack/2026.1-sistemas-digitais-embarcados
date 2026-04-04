# Modelagem Logica

## Interface considerada nesta etapa

Para a continuidade do projeto na Tang Nano 9K, os 4 bits do codigo foram mantidos como entradas digitais independentes, mas representados por botoes externos no protoboard:

- `B3`: bit mais significativo do codigo
- `B2`: segundo bit do codigo
- `B1`: terceiro bit do codigo
- `B0`: bit menos significativo do codigo
- `BTN_CONFIRM`: confirma a tentativa de acesso
- `BTN_RESET`: reinicia o sistema

Durante o uso, os botoes `B3..B0` equivalem logicamente aos antigos switches: os bits desejados devem ficar mantidos no estado ativo enquanto `BTN_CONFIRM` e pressionado.

Saidas:

- `LED0`: acesso autorizado
- `LED1`: acesso negado
- `LED2`: tentativa em andamento/registrada no instante da confirmacao
- `LED5..LED3`: contador de tentativas

## Codigo valido

O codigo de acesso valido e `1011`.

| B3 | B2 | B1 | B0 | F |
|---:|---:|---:|---:|---:|
| 0 | 0 | 0 | 0 | 0 |
| 0 | 0 | 0 | 1 | 0 |
| 0 | 0 | 1 | 0 | 0 |
| 0 | 0 | 1 | 1 | 0 |
| 0 | 1 | 0 | 0 | 0 |
| 0 | 1 | 0 | 1 | 0 |
| 0 | 1 | 1 | 0 | 0 |
| 0 | 1 | 1 | 1 | 0 |
| 1 | 0 | 0 | 0 | 0 |
| 1 | 0 | 0 | 1 | 0 |
| 1 | 0 | 1 | 0 | 0 |
| 1 | 0 | 1 | 1 | 1 |
| 1 | 1 | 0 | 0 | 0 |
| 1 | 1 | 0 | 1 | 0 |
| 1 | 1 | 1 | 0 | 0 |
| 1 | 1 | 1 | 1 | 0 |

## Expressao booleana

Em forma canonica:

`F(B3,B2,B1,B0) = Σm(11)`

Como existe apenas um mintermo valido, a expressao direta ja e:

`F = B3 . ~B2 . B1 . B0`

## Simplificacao

A simplificacao por algebra booleana ou mapa de Karnaugh leva ao mesmo resultado, pois existe apenas uma combinacao valida e nenhum agrupamento adicional pode ser feito.

Mapa de Karnaugh de `F`:

| B3B2 \ B1B0 | 00 | 01 | 11 | 10 |
|---|---:|---:|---:|---:|
| 00 | 0 | 0 | 0 | 0 |
| 01 | 0 | 0 | 0 | 0 |
| 11 | 0 | 0 | 0 | 0 |
| 10 | 0 | 0 | 1 | 0 |

Portanto, a implementacao combinacional usada no projeto permanece:

`F = B3 . ~B2 . B1 . B0`
