.section .text
.global _start
_start:
    mov w19, #0x7fffffff               // maior signed de 32 bits
    adds w19, w19, #1                  // soma em 32 bits e atualiza flags (V=1 em overflow signed)

    b.vs overflow_detectado            // se V=1, houve overflow com sinal

sem_overflow:
    mov x0, #0                         // retorno 0 quando nao detecta overflow
    b exit_prog

overflow_detectado:
    mov x0, #1                         // retorno 1 quando detecta overflow

exit_prog:
    mov x8, #93                        // syscall exit (AArch64 Linux)
    svc #0                             // encerra com o status em x0
