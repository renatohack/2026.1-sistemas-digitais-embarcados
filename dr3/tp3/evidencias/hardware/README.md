# Evidencias de Hardware

Salvar aqui as evidencias manuais da Tang Nano 9K:

- `montagem_botoes.jpg`: foto geral da placa e do protoboard pequeno com os quatro botoes.
- `leds_estado_inicial.jpg`: reset/estado inicial, com PASS ligado para `M0 O0 C0`.
- `leds_overflow.jpg`: caso com flag de overflow ou underflow, mostrando o LED de flags ligado.
- `leds_saturacao.jpg`: caso de ponto fixo com saturacao.
- `serial_uart_resultados.png`: terminal serial em 115200 8N1 mostrando as linhas `TP3 Mx Oy Cz ... P=1`.

Os botoes externos devem ligar os pinos 25, 26, 27 e 28 ao GND quando pressionados.

Nao use 3V3 nem 5V nos botoes. Os pinos usam pull-up interno, entao o circuito correto e:

```text
pino da Tang -> botao -> GND comum
```

Linha UART esperada no reset:

```text
TP3 mode=UINT8  op=ADD case=0 A=0C B=05 result=11 flags=00 OK        pass=YES
```
