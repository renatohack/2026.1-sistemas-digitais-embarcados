.data
.balign 8
result_ok:
    .quad 0
result_zero_div:
    .quad 0
result_overflow_guard:
    .quad 0
sat_expected:
    .quad 9223372036854775807
.balign 4
status_ok:
    .word 0
status_zero_div:
    .word 0
status_overflow_guard:
    .word 0

.text
.global _start

_start:
    mov x0, #1000
    mov x1, #10
    bl safe_div_s64
after_ok_case:
    adr x9, result_ok
    str x0, [x9]
    adr x9, status_ok
    str w1, [x9]

    mov x0, #1000
    mov x1, xzr
    bl safe_div_s64
after_div_zero:
    adr x9, result_zero_div
    str x0, [x9]
    adr x9, status_zero_div
    str w1, [x9]

    mov x0, #1
    lsl x0, x0, #63
    mov x1, #-1
    bl safe_div_s64
after_overflow_guard:
    adr x9, result_overflow_guard
    str x0, [x9]
    adr x9, status_overflow_guard
    str w1, [x9]

    adr x9, result_ok
    ldr x10, [x9]
    cmp x10, #100
    b.ne .fail

    adr x9, status_ok
    ldr w10, [x9]
    cmp w10, #0
    b.ne .fail

    adr x9, sat_expected
    ldr x11, [x9]

    adr x9, result_zero_div
    ldr x10, [x9]
    cmp x10, x11
    b.ne .fail

    adr x9, status_zero_div
    ldr w10, [x9]
    cmp w10, #1
    b.ne .fail

    adr x9, result_overflow_guard
    ldr x10, [x9]
    cmp x10, x11
    b.ne .fail

    adr x9, status_overflow_guard
    ldr w10, [x9]
    cmp w10, #2
    b.ne .fail

    mov w0, wzr
    b .exit

.fail:
    mov w0, #1

.exit:
    mov x8, #93
    svc #0

.section .note.GNU-stack,"",@progbits
