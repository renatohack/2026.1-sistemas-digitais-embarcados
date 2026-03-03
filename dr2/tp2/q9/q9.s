.section .text
.global _start
_start:
    mov x19, #111             // Valores originais dos registradores de trabalho.
    mov x20, #222

sp_before:
    sub sp, sp, #16           // Reserva 16 bytes na pilha.
    str x19, [sp, #0]
    str x20, [sp, #8]

    mov x19, #0               // Simula uso temporario dos registradores.
    mov x20, #0

    ldr x19, [sp, #0]         // Restaura os valores originais.
    ldr x20, [sp, #8]
    add sp, sp, #16           // Libera exatamente o que foi reservado.

sp_after:
done:
    mov x8, #93
    mov x0, #0
    svc #0
