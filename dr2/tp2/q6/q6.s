.section .data
calib:
    .word 10, 20, 30, 40, 50, 60
checksum:
    .quad 0                   // Resultado final de 64 bits.

.section .text
.global _start
_start:
    ldr x0, =calib

    ldr w1, [x0, #4]          // calib[1]
    ldr w2, [x0, #12]         // calib[3]
    ldr w3, [x0, #20]         // calib[5]

    add w4, w1, w2
    add w4, w4, w3            // 20 + 40 + 60 = 120.

    ldr x5, =checksum
    str x4, [x5]              // Grava 120 em checksum (64 bits).

done:
    mov x8, #93
    mov x0, #0
    svc #0
