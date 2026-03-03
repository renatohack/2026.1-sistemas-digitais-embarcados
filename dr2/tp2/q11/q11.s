.section .data
coef:
    .quad 2, 4, 8, 16, 32
prod:
    .quad 0

.section .text
.global _start
_start:
    ldr x0, =coef             // Endereco base do vetor de 64 bits.

    mov x9, #0
    mov x10, #2
    mov x11, #4

    ldr x1, [x0, x9, lsl #3]  // coef[0]
    ldr x2, [x0, x10, lsl #3] // coef[2]
    ldr x3, [x0, x11, lsl #3] // coef[4]

    mul x4, x1, x2
    mul x4, x4, x3            // 2 * 8 * 32 = 512.

    ldr x5, =prod
    str x4, [x5]              // Grava o produto final em memoria.

done:
    mov x8, #93
    mov x0, #0
    svc #0
