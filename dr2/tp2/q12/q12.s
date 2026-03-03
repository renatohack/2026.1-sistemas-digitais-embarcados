.equ SCALE, 3

.section .data
v:
    .word 5, 10, 15, 20
scaled:
    .quad 0
msg:
    .asciz "DR2-MEM\n"

.section .bss
flag:
    .skip 8

.section .text
.global _start
_start:
sp_before:
    sub sp, sp, #16           // Reserva area temporaria na pilha.
    mov x19, #0x1234
    str x19, [sp, #0]         // Salva registrador de trabalho.

    ldr x0, =v
    ldr w1, [x0, #0]          // v[0]
    ldr w2, [x0, #4]          // v[1]
    ldr w3, [x0, #8]          // v[2]

    add w4, w1, w2
    add w4, w4, w3            // 5 + 10 + 15 = 30.
    mov w5, #SCALE
    mul w4, w4, w5            // 30 * 3 = 90.

    ldr x6, =scaled
    str x4, [x6]              // Persiste valor numerico em .data.

    ldr x7, =msg              // Ponteiro para conversao da string in-place.

lower_loop:
    ldrb w8, [x7]
    cbz w8, lower_done

    cmp w8, #'A'
    blt lower_next
    cmp w8, #'Z'
    bgt lower_next

    add w8, w8, #32
    strb w8, [x7]             // Escreve letra minuscula no mesmo buffer.

lower_next:
    add x7, x7, #1
    b lower_loop

lower_done:
    ldr x9, =flag
    mov x10, #1
    str x10, [x9]             // Usa simbolo em .bss para evidenciar secao.

    ldr x19, [sp, #0]
    add sp, sp, #16           // Restaura SP ao valor original.

sp_after:
done:
    mov x8, #93
    mov x0, #0
    svc #0
