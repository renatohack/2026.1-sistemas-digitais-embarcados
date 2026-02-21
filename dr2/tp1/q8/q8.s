.section .text
.global _start
_start:
    mov x19, #9                        // A = 9
    mov x20, #12                       // B = 12

    cmp x19, x20                       // compara A com B (atualiza flags)
    b.lt a_menor                       // A < B
    b.eq a_igual                       // A == B
    b.gt a_maior                       // A > B

a_menor:
    mov x0, #0                         // retorno 0 para A < B
    b exit_prog

a_igual:
    mov x0, #1                         // retorno 1 para A == B
    b exit_prog

a_maior:
    mov x0, #2                         // retorno 2 para A > B

exit_prog:
    mov x8, #93                        // syscall exit (AArch64 Linux)
    svc #0                             // encerra com o valor em x0
