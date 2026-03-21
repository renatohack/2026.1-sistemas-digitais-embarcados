.data
coef_ok:
    .word 131072, 196608, 65536
coef_sat:
    .word 2147483647, 2147483647
result_ok:
    .word 0
result_sat:
    .word 0
result_bad_n:
    .word 0
result_null:
    .word 0
status_ok:
    .word 0
status_sat:
    .word 0
status_bad_n:
    .word 0
status_null:
    .word 0

.text
.global _start

_start:
    adr x0, coef_ok
    mov x1, #3
    mov w2, #262144
    bl poly_horner_q16_sat
after_simple_case:
    adr x9, result_ok
    str w0, [x9]
    adr x9, status_ok
    str w1, [x9]

    adr x0, coef_sat
    mov x1, #2
    mov w2, #131072
    bl poly_horner_q16_sat
after_saturation_case:
    adr x9, result_sat
    str w0, [x9]
    adr x9, status_sat
    str w1, [x9]

    adr x0, coef_ok
    mov x1, xzr
    mov w2, #262144
    bl poly_horner_q16_sat
after_bad_n_case:
    adr x9, result_bad_n
    str w0, [x9]
    adr x9, status_bad_n
    str w1, [x9]

    mov x0, xzr
    mov x1, #3
    mov w2, #262144
    bl poly_horner_q16_sat
after_null_case:
    adr x9, result_null
    str w0, [x9]
    adr x9, status_null
    str w1, [x9]

    adr x9, result_ok
    ldr w10, [x9]
    mov w11, #2949120
    cmp w10, w11
    b.ne .fail

    adr x9, status_ok
    ldr w10, [x9]
    cbnz w10, .fail

    adr x9, result_sat
    ldr w10, [x9]
    mov w11, #0x7fffffff
    cmp w10, w11
    b.ne .fail

    adr x9, status_sat
    ldr w10, [x9]
    cmp w10, #3
    b.ne .fail

    adr x9, result_bad_n
    ldr w10, [x9]
    cbnz w10, .fail

    adr x9, status_bad_n
    ldr w10, [x9]
    cmp w10, #2
    b.ne .fail

    adr x9, result_null
    ldr w10, [x9]
    cbnz w10, .fail

    adr x9, status_null
    ldr w10, [x9]
    cmp w10, #1
    b.ne .fail

    mov w0, wzr
    b .exit

.fail:
    mov w0, #1

.exit:
    mov x8, #93
    svc #0

.section .note.GNU-stack,"",@progbits
