.section .text
.global _start
_start:
    mov x19, #9                        // carrega o valor inicial
    subs x19, x19, #9                  // 9 - 9 = 0 e atualiza flags (Z=1 se zerou)

    b.eq zero_detectado                // se Z=1, segue caminho de "zero detectado"

nao_zero:
    mov x0, #1                         // retorno 1 quando nao for zero
    b exit_prog

zero_detectado:
    mov x0, #0                         // retorno 0 quando for zero

exit_prog:
    mov x8, #93                        // syscall exit (AArch64 Linux)
    svc #0                             // encerra com o status em x0
