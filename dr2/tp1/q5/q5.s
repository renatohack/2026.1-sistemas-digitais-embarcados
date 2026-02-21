.section .text
.global _start
_start:
    mov x19, #3                        // operando inicial
    sub x19, x19, #8                   // 3 - 8 = -5 (complemento de dois em 64 bits)

before_exit:
    mov x0, #0                         // arg1 do exit: retorno 0
    mov x8, #93                        // syscall exit (AArch64 Linux)
    svc #0                             // encerra o processo
