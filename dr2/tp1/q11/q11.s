.section .text
.global _start
_start:
    mov x19, #-1                       // X = 0xFFFFFFFFFFFFFFFF
    mov x20, #1                        // Y = 1

    mov x0, #0                         // retorno em 2 bits: bit0=signed, bit1=unsigned

    cmp x19, x20                       // comparacao signed de X < Y
    b.lt signed_true                   // se true, liga bit0
    b signed_done

signed_true:
    orr x0, x0, #1                     // x0 |= 0b01

signed_done:
    cmp x19, x20                       // comparacao unsigned de X < Y
    b.lo unsigned_true                 // se true, liga bit1
    b exit_prog

unsigned_true:
    orr x0, x0, #2                     // x0 |= 0b10

exit_prog:
    mov x8, #93                        // syscall exit (AArch64 Linux)
    svc #0                             // encerra com o valor codificado em x0
