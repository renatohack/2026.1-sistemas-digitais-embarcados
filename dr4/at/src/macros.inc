    .macro LOAD_ADDR reg, sym
        adrp \reg, \sym
        add \reg, \reg, :lo12:\sym
    .endm

    .macro WRITE_STDOUT label, len
        mov x0, #1
        LOAD_ADDR x1, \label
        mov x2, #\len
        mov x8, #64
        svc #0
    .endm

    .macro WRITE_REG buf_reg, len_reg
        mov x0, #1
        mov x1, \buf_reg
        mov x2, \len_reg
        mov x8, #64
        svc #0
    .endm

    .macro EXIT_PROGRAM code
        mov x0, #\code
        mov x8, #93
        svc #0
    .endm
