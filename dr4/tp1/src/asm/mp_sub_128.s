.text
.align 2

.global mp_sub_128
.global mp_sub_128_after_low
.global mp_sub_128_after_high
.type mp_sub_128, %function
mp_sub_128:
    ldr x3, [x0]
    ldr x4, [x0, #8]
    ldr x5, [x1]
    ldr x6, [x1, #8]

    subs x7, x3, x5
mp_sub_128_after_low:
    sbcs x8, x4, x6
mp_sub_128_after_high:
    str x7, [x2]
    str x8, [x2, #8]
    cset x0, cc
    ret
.size mp_sub_128, . - mp_sub_128
