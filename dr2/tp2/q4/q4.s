.section .data
op_a:
    .quad 30
op_b:
    .quad 12
result:
    .quad 0                   // Resultado de 64 bits em memoria.

.section .text
.global _start
_start:
    ldr x0, =op_a
    ldr x1, [x0]              // Le op_a.

    ldr x0, =op_b
    ldr x2, [x0]              // Le op_b.

    add x3, x1, x2            // Soma em registradores.

    ldr x0, =result
    str x3, [x0]              // Grava o resultado com STR.

done:
    mov x8, #93
    mov x0, #0
    svc #0
