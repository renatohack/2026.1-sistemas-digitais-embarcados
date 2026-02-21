.section .text
.global _start
_start:
    mov x19, #15                       // inicia R com 15
    sub x19, x19, #5                   // R = 15 - 5

    cmp x19, #10                       // compara R com 10
    b.eq igual                         // se R == 10, vai para retorno 1

nao_igual:
    mov x0, #0                         // retorno 0 quando nao for igual
    b exit_prog

igual:
    mov x0, #1                         // retorno 1 quando for igual

exit_prog:
    mov x8, #93                        // syscall exit (AArch64 Linux)
    svc #0                             // encerra com o status em x0
