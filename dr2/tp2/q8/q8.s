.section .data
s:
    .asciz "A1-b?\n"
s_guard:
    .byte 0xDD, 0xEE, 0xFF    // Guarda para evidenciar limite da escrita.

.section .text
.global _start
_start:
    ldr x0, =s                // x0: leitura.
    mov x1, x0                // x1: escrita (in-place).
    mov w4, #0                // w4=1 quando ultimo byte gravado foi espaco.

loop:
    ldrb w2, [x0], #1
    cbz w2, finish            // Encerra ao chegar no 0x00.

    cmp w2, #'\n'
    beq write_newline         // Mantem quebra de linha.

    cmp w2, #'A'
    blt not_letter
    cmp w2, #'Z'
    ble write_letter

    cmp w2, #'a'
    blt not_letter
    cmp w2, #'z'
    ble write_letter

not_letter:
    cbnz w4, loop             // Evita escrever espacos duplicados seguidos.
    mov w3, #0x20
    strb w3, [x1], #1
    mov w4, #1
    b loop

write_letter:
    strb w2, [x1], #1
    mov w4, #0
    b loop

write_newline:
    strb w2, [x1], #1
    mov w4, #0
    b loop

finish:
    strb wzr, [x1]            // Finaliza com terminador nulo.

done:
    mov x8, #93
    mov x0, #0
    svc #0
