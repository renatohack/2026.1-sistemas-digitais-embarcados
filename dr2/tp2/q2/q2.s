.section .data
init_data:
    .quad 99                  // Dado inicializado em .data.

.section .bss
scratch:
    .skip 8                   // Dado nao inicializado em .bss.

.section .text
.global _start
_start:
work:
    ldr x0, =init_data
    ldr x1, [x0]              // Le o dado inicializado.

    ldr x2, =scratch
    str x1, [x2]              // Escreve o valor em .bss para manter fluxo linear.

done:
    mov x8, #93
    mov x0, #0
    svc #0
