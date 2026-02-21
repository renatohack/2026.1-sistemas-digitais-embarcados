.section .text
.global _start
_start:
    mov x19, #10                       // inicia R com 10
    add x19, x19, #7                   // R = R + 7
    sub x19, x19, #3                   // R = R - 3 (resultado final: 14)

before_exit:
    mov x0, #0                         // arg1 do exit: retorno 0
    mov x8, #93                        // syscall exit (AArch64 Linux)
    svc #0                             // encerra o processo
