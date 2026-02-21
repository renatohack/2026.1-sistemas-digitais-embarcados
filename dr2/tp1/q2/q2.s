.section .data
msg:
    .ascii "DR2 TP1 OK\n"
len = . - msg

.section .text
.global _start
_start:
    mov x0, #1                         // arg1 do write: fd=1 (stdout)
    ldr x1, =msg                       // arg2 do write: endereco da string
    mov x2, #len                       // arg3 do write: tamanho em bytes
    mov x8, #64                        // syscall write (AArch64 Linux)
    svc #0                             // executa write

    mov x0, #0                         // arg1 do exit: retorno 0
    mov x8, #93                        // syscall exit (AArch64 Linux)
    svc #0                             // encerra o processo
