.section .text
.global _start
_start:
    mov x19, #'g'                      // entrada ASCII fixa: 'g' (0x67)
    sub x19, x19, #32                  // converte para maiuscula: 'G' (0x47)

before_exit:
    mov x0, #0                         // arg1 do exit: retorno 0
    mov x8, #93                        // syscall exit (AArch64 Linux)
    svc #0                             // encerra o processo
