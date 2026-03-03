.section .data
w:
    .word 0x12345678          // Palavra usada para provar endianness.
w_bytes:
    .space 4                  // Buffer de 4 bytes em .data.

.section .text
.global _start
_start:
    ldr x0, =w
    ldr w1, [x0]              // Le os 32 bits de w.

    ldr x2, =w_bytes
    str w1, [x2]              // Escreve os mesmos 4 bytes no buffer auxiliar.

done:
    mov x8, #93
    mov x0, #0
    svc #0
