# Guia de Evidencias de Hardware

Faca os passos abaixo no Windows, nesta ordem. Nao e necessario usar
protoboard.

## Antes de comecar

1. Conecte a Tang Nano 9K ao computador por USB-C.
2. Abra o Gowin EDA.
3. Abra o projeto `dr3_at.gprj`.
4. Confirme que o top level e `signal_monitor_top`.
5. Confirme que o device e `GW1NR-LV9QN88PC6/I5`.
6. Confirme que estes arquivos aparecem habilitados no projeto:

```text
constraints/tangnano9k.cst
constraints/tangnano9k.sdc
```

## Evidencia 01 - Relatorio de utilizacao do Gowin

Objetivo: comprovar que a sintese utilizou os recursos internos da FPGA.

1. No Gowin EDA, execute `Process -> Synthesize`.
2. Aguarde a sintese terminar sem erros.
3. Execute `Process -> Place & Route`.
4. Aguarde o place/route terminar sem erros.
5. No VS Code, abra este arquivo gerado pelo Gowin:

```text
impl/pnr/dr3_at.rpt.txt
```

6. Localize a secao:

```text
3. Resource Usage Summary
```

7. Tire um print deixando visiveis estas linhas:

```text
BSRAM | 1/26 | 4%
--SP  | 1
DSP   | 0.5/10 | 5%
--MULT18X18 | 1
```

8. Salve como:

```text
evidencias/hardware/01_relatorio_utilizacao_gowin.png
```

9. No mesmo arquivo, localize a secao:

```text
5. Clock Resource Usage Summary
```

10. Tire um print deixando visivel:

```text
rPLL | 1/2 | 50%
```

11. Salve como:

```text
evidencias/hardware/01b_relatorio_pll.png
```

O Gowin tambem gerou uma versao HTML do mesmo relatorio:

```text
impl/pnr/dr3_at.rpt.html
```

Use o TXT para as evidencias porque as linhas ficam mais faceis de enquadrar.

## Evidencia 02 - Placa conectada

Objetivo: mostrar a Tang Nano 9K fisicamente em funcionamento.

1. No Gowin EDA, gere o bitstream com `Process -> Program Device` ou execute
   todas as etapas necessarias ate gerar o arquivo `.fs`.
2. Abra o Gowin Programmer.
3. Programe a Tang Nano 9K.
4. Aguarde a placa iniciar.
5. Tire uma foto mostrando:
   - a placa inteira;
   - o cabo USB-C conectado;
   - o LED inicial aceso.
6. Salve como:

```text
evidencias/hardware/02_placa_conectada_idle.jpeg
```

## Evidencia 03 - Estado final DONE

Objetivo: mostrar que o processamento foi iniciado e terminou.

1. Com a placa programada, identifique os dois botoes onboard.
2. Pressione um deles. Se a placa voltar ao mesmo LED inicial, esse botao e o
   reset.
3. Pressione o outro botao uma vez. Esse botao e o START.
4. Aguarde alguns milissegundos.
5. Confira que outro LED permanece aceso. Esse e o estado `DONE`.
6. Tire uma foto da placa mostrando o LED final aceso.
7. Salve como:

```text
evidencias/hardware/03_estado_done_leds.jpeg
```

Nao tire foto do estado intermediario de processamento. Ele e rapido demais
para uma foto comum e ja esta demonstrado pelas waveforms de simulacao.

## Evidencia 04 - Resultado UART no Windows

Objetivo: comprovar em hardware real que a FPGA transmitiu as metricas
calculadas.

1. Abra o PowerShell no Windows.
2. Descubra qual porta COM pertence a placa:

```powershell
Get-CimInstance Win32_SerialPort | Select-Object DeviceID, Description
```

3. Anote a porta, por exemplo `COM5`.
4. Abra um terminal serial em `115200 8N1`, sem controle de fluxo.

Opcao com PuTTY:

```powershell
putty.exe -serial COM5 -sercfg 115200,8,n,1,N
```

Troque `COM5` pela porta encontrada no passo 3.

Opcao com PowerShell puro:

```powershell
$portName = "COM5"
$serial = [System.IO.Ports.SerialPort]::new($portName, 115200, [System.IO.Ports.Parity]::None, 8, [System.IO.Ports.StopBits]::One)
$serial.ReadTimeout = 1000
$serial.Open()
try {
    while ($true) {
        try {
            $line = $serial.ReadLine()
            Write-Host $line
        } catch [System.TimeoutException] {
        }
    }
} finally {
    $serial.Close()
}
```

5. Com o terminal serial aberto, pressione START uma vez.
6. Confira se aparece:

```text
DR3_AT N=16 SUM=0x00000040 MEAN=0x00000004 RMS2=0x00000170 DONE
```

7. Tire um print da janela mostrando a mensagem completa.
8. Salve como:

```text
evidencias/hardware/04_terminal_uart_resultados.png
```

## Arquivos obrigatorios ao final

```text
evidencias/hardware/01_relatorio_utilizacao_gowin.png
evidencias/hardware/01b_relatorio_pll.png
evidencias/hardware/02_placa_conectada_idle.jpeg
evidencias/hardware/03_estado_done_leds.jpeg
evidencias/hardware/04_terminal_uart_resultados.png
```
