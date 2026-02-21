.section .text
.global _start
_start:
    mov x19, #10                       // X = 10

    cmp x19, #0                        // checa limite inferior
    b.lt fora_faixa                    // se X < 0, esta fora

    cmp x19, #10                       // checa limite superior
    b.gt fora_faixa                    // se X > 10, esta fora

    mov x0, #0                         // dentro da faixa [0,10]
    b exit_prog

fora_faixa:
    mov x0, #1                         // fora da faixa

exit_prog:
    mov x8, #93                        // syscall exit (AArch64 Linux)
    svc #0                             // encerra com o status em x0
