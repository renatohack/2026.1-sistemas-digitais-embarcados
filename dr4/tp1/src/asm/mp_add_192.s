.text
.align 2

.global mp_add_192
.global mp_add_192_after_w0
.global mp_add_192_after_w1
.type mp_add_192, %function
mp_add_192:
    ldr x3, [x0]
    ldr x4, [x0, #8]
    ldr x5, [x0, #16]
    ldr x6, [x1]
    ldr x7, [x1, #8]
    ldr x8, [x1, #16]

    adds x9, x3, x6
mp_add_192_after_w0:
    adcs x10, x4, x7
mp_add_192_after_w1:
    adcs x11, x5, x8

    str x9, [x2]
    str x10, [x2, #8]
    str x11, [x2, #16]
    cset x0, cs
    ret
.size mp_add_192, . - mp_add_192
