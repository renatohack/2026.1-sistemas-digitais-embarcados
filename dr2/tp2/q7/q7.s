.section .data
msg:
    .asciz "InfNET-DR2!\n"
msg_guard:
    .byte 0xAA, 0xBB, 0xCC    // Bytes de guarda apos o terminador.

.section .text
.global _start
_start:
    ldr x0, =msg              // Ponteiro para o inicio da string.

loop:
    ldrb w1, [x0]
    cbz w1, end_loop          // Para no terminador 0x00.

    cmp w1, #'A'
    blt next_char
    cmp w1, #'Z'
    bgt next_char

    add w1, w1, #32           // Converte A..Z para a..z.
    strb w1, [x0]             // Escreve no mesmo buffer (in-place).

next_char:
    add x0, x0, #1
    b loop

end_loop:
done:
    mov x8, #93
    mov x0, #0
    svc #0
