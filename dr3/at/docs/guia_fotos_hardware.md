# Guia de Fotos da Placa

Use os nomes abaixo para que o relatorio ja aponte para os caminhos corretos.

## Fotos e capturas obrigatorias

- `evidencias/hardware/01_placa_conectada.jpg`
  - Foto da Tang Nano 9K conectada por USB ao computador.
  - A placa inteira deve aparecer, incluindo USB-C e LEDs.

- `evidencias/hardware/02_estado_processando.jpg`
  - Foto ou frame logo apos pressionar START.
  - Mostre o dedo no botao onboard ou a placa imediatamente apos o acionamento.

- `evidencias/hardware/03_estado_done_leds.jpg`
  - Foto dos LEDs no estado final.
  - O LED correspondente a `DONE` deve estar ativo.

- `evidencias/hardware/04_terminal_uart_resultados.png`
  - Print do terminal serial conectado ao USB-UART da Tang Nano 9K.
  - A mensagem esperada e:

```text
DR3_AT N=16 SUM=0x00000040 MEAN=0x00000004 RMS2=0x00000170 DONE
```

## Terminal serial

Como o Gowin esta instalado no Windows e o VS Code esta rodando pelo WSL, faca a validacao da UART no Windows. Nao use `/dev/ttyUSB*` no Linux/WSL para esta evidencia, porque a porta serial USB da Tang Nano 9K normalmente fica associada ao Windows.

Configuracao da UART:

- Baud rate: `115200`
- Formato: `8N1`
- Controle de fluxo: nenhum

## Sequencia para obter a evidencia da UART no Windows

1. Conecte a Tang Nano 9K ao Windows por USB.
2. Abra o Gowin EDA no Windows.
3. Abra o projeto `dr3_at.gprj`.
4. Rode sintese, place/route e gere o bitstream.
5. Abra o Gowin Programmer e programe a FPGA.
6. Feche o Programmer se o terminal serial nao conseguir abrir a porta.
7. Descubra a porta COM da placa no PowerShell:

```powershell
Get-CimInstance Win32_SerialPort | Select-Object DeviceID, Description
```

Alternativa pelo Gerenciador de Dispositivos:

```text
Gerenciador de Dispositivos -> Portas (COM e LPT) -> anotar COMx
```

8. Abra um terminal serial no Windows em `115200 8N1`, sem controle de fluxo.

Opcao com PuTTY, se estiver instalado no PATH:

```powershell
putty.exe -serial COM5 -sercfg 115200,8,n,1,N
```

Troque `COM5` pela porta encontrada no passo 7.

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

9. Com o terminal serial ja aberto, pressione o botao START onboard.
10. Confirme que aparece a linha:

```text
DR3_AT N=16 SUM=0x00000040 MEAN=0x00000004 RMS2=0x00000170 DONE
```

11. Tire o print da janela do terminal mostrando a porta COM, a configuracao `115200 8N1` se visivel, e a mensagem completa.
12. Salve o print como:

```text
evidencias/hardware/04_terminal_uart_resultados.png
```

## Evidencias especificas da UART

Para a UART, o relatorio espera uma evidencia principal:

- `evidencias/hardware/04_terminal_uart_resultados.png`
  - Deve mostrar a mensagem completa recebida pelo Windows.
  - Deve ser gerada depois de programar a FPGA e pressionar START.
  - A mensagem deve conter `SUM=0x00000040`, `MEAN=0x00000004` e `RMS2=0x00000170`.

Se quiser registrar uma evidencia extra para o video ou para sua conferencia, salve tambem:

- `evidencias/hardware/05_porta_com_windows.png`
  - Print do Gerenciador de Dispositivos ou PowerShell mostrando qual `COMx` pertence a Tang Nano 9K.
