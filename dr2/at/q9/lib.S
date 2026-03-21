.text
.global affine2d_q16
.type affine2d_q16, %function

affine2d_q16:
    cbz x1, .null_ptr
    cbz x2, .null_ptr
    cbz x3, .null_ptr
    cbz x4, .null_ptr

    cmp w0, #0
    b.eq .mode_ap
    cmp w0, #1
    b.eq .mode_apb

    mov w0, #2
    ret

.mode_ap:
    ldr w5, [x1]
    ldr w6, [x1, #4]
    ldr w7, [x1, #8]
    ldr w8, [x1, #12]
    ldr w9, [x3]
    ldr w10, [x3, #4]

    smull x11, w5, w9
    smull x12, w6, w10
    add x11, x11, x12
    asr x11, x11, #16

    smull x13, w7, w9
    smull x14, w8, w10
    add x13, x13, x14
    asr x13, x13, #16

    str w11, [x4]
    str w13, [x4, #4]
    mov w0, wzr
    ret

.mode_apb:
    ldr w5, [x1]
    ldr w6, [x1, #4]
    ldr w7, [x1, #8]
    ldr w8, [x1, #12]
    ldr w9, [x3]
    ldr w10, [x3, #4]
    ldr w15, [x2]
    ldr w16, [x2, #4]

    smull x11, w5, w9
    smull x12, w6, w10
    add x11, x11, x12
    asr x11, x11, #16
    sxtw x15, w15
    add x11, x11, x15

    smull x13, w7, w9
    smull x14, w8, w10
    add x13, x13, x14
    asr x13, x13, #16
    sxtw x16, w16
    add x13, x13, x16

    str w11, [x4]
    str w13, [x4, #4]
    mov w0, wzr
    ret

.null_ptr:
    mov w0, #1
    ret

.section .note.GNU-stack,"",@progbits
