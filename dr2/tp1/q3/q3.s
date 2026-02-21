.section .text
.global _start
_start:
    mov x0, #7                         // arg1 do exit: codigo de retorno 7
    mov x8, #93                        // syscall exit (AArch64 Linux)
    svc #0                             // encerra o processo
