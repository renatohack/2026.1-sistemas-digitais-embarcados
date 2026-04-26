# Pinagem fisica x BCM - Raspberry Pi Zero 2W

Tabela de referencia para conectar a numeracao fisica do header de 40 pinos ao identificador BCM usado em software e em MMIO.

| Pino fisico | Sinal | BCM | Observacao |
| --- | --- | --- | --- |
| 1 | 3V3 | N/A | Alimentacao 3,3 V |
| 2 | 5V | N/A | Alimentacao 5 V |
| 3 | SDA1 | GPIO2 | I2C1 SDA |
| 5 | SCL1 | GPIO3 | I2C1 SCL |
| 6 | GND | N/A | Terra |
| 7 | GPIO4 | GPIO4 | GPIO geral |
| 8 | TXD0 | GPIO14 | UART0 TX |
| 10 | RXD0 | GPIO15 | UART0 RX |
| 11 | GPIO17 | GPIO17 | GPIO geral |
| 12 | GPIO18 | GPIO18 | GPIO/PWM |
| 13 | GPIO27 | GPIO27 | GPIO geral |
| 15 | GPIO22 | GPIO22 | GPIO geral |
| 16 | GPIO23 | GPIO23 | GPIO geral |
| 18 | GPIO24 | GPIO24 | GPIO geral |
| 19 | MOSI | GPIO10 | SPI0 MOSI |
| 21 | MISO | GPIO9 | SPI0 MISO |
| 22 | GPIO25 | GPIO25 | GPIO geral |
| 23 | SCLK | GPIO11 | SPI0 SCLK |
| 24 | CE0 | GPIO8 | SPI0 CE0 |
| 29 | GPIO5 | GPIO5 | GPIO geral |
| 31 | GPIO6 | GPIO6 | GPIO geral |
| 32 | GPIO12 | GPIO12 | GPIO/PWM |
| 33 | GPIO13 | GPIO13 | GPIO/PWM |
| 35 | GPIO19 | GPIO19 | GPIO/SPI1 |
| 36 | GPIO16 | GPIO16 | GPIO geral |
| 37 | GPIO26 | GPIO26 | GPIO geral |
| 38 | GPIO20 | GPIO20 | GPIO/SPI1 |
| 40 | GPIO21 | GPIO21 | GPIO/SPI1 |

## Uso no projeto

- A camada fisica e documentada em termos de `pino fisico`.
- O software em Assembly trabalha com `BCM`, porque os registradores de GPIO selecionam funcoes por numero logico do GPIO.
- O mapeamento evita ambiguidade ao documentar cabos, pinos de teste e acessos a registradores.
