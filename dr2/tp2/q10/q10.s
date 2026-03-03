.section .data
sum:
    .quad 0

.section .text
.global _start
_start:
    sub sp, sp, #32           // Quadro local com espaco para 3 temporarios de 64 bits.

    mov x0, #3
    str x0, [sp, #0]          // temp0 = 3
    mov x0, #5
    str x0, [sp, #8]          // temp1 = 5
    mov x0, #7
    str x0, [sp, #16]         // temp2 = 7

frame_ready:
    ldr x1, [sp, #0]
    ldr x2, [sp, #8]
    ldr x3, [sp, #16]
    add x4, x1, x2
    add x4, x4, x3            // Soma = 15.

    ldr x5, =sum
    str x4, [x5]              // Grava o resultado em .data.

    add sp, sp, #32           // Desaloca o quadro local.

done:
    mov x8, #93
    mov x0, #0
    svc #0
