.equ MAX_TEMP, 75

.section .data
current_temp:
    .quad 42                  // Variavel inicializada em .data.

.section .bss
alarm_flag:
    .skip 8                   // Variavel nao inicializada em .bss.

.section .text
.global _start
_start:
    mov x1, #MAX_TEMP         // Coloca a constante de montagem em um registrador.

    ldr x0, =current_temp
    ldr x2, [x0]              // Le current_temp da memoria para outro registrador.

done:
    mov x8, #93
    mov x0, #0
    svc #0
