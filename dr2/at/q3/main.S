.data
vec_a_ok:
    .word 1, -2, 3
vec_b_ok:
    .word 4, 5, 6
vec_big_a:
    .word 2147483647, 2147483647, 2147483647
vec_big_b:
    .word 2147483647, 2147483647, 2147483647
.balign 8
acc_ok:
    .quad 0
acc_overflow:
    .quad 0
expected_overflow_acc:
    .quad 9223372028264841218
.balign 4
status_ok:
    .word 0
status_overflow:
    .word 0
status_zero:
    .word 0
status_null:
    .word 0

.text
.global _start

_start:
    adr x0, vec_a_ok
    adr x1, vec_b_ok
    mov x2, #3
    bl dot_i32_checked
after_ok_case:
    adr x9, acc_ok
    str x0, [x9]
    adr x9, status_ok
    str w1, [x9]

    adr x0, vec_big_a
    adr x1, vec_big_b
    mov x2, #3
    bl dot_i32_checked
after_overflow_case:
    adr x9, acc_overflow
    str x0, [x9]
    adr x9, status_overflow
    str w1, [x9]

    adr x0, vec_a_ok
    adr x1, vec_b_ok
    mov x2, #0
    bl dot_i32_checked
after_zero_case:
    adr x9, status_zero
    str w1, [x9]

    mov x0, xzr
    adr x1, vec_b_ok
    mov x2, #1
    bl dot_i32_checked
after_null_case:
    adr x9, status_null
    str w1, [x9]

    adr x9, acc_ok
    ldr x10, [x9]
    cmp x10, #12
    b.ne .fail

    adr x9, status_ok
    ldr w10, [x9]
    cmp w10, #0
    b.ne .fail

    adr x9, status_overflow
    ldr w10, [x9]
    cmp w10, #3
    b.ne .fail

    adr x9, acc_overflow
    ldr x10, [x9]
    adr x11, expected_overflow_acc
    ldr x12, [x11]
    cmp x10, x12
    b.ne .fail

    adr x9, status_zero
    ldr w10, [x9]
    cmp w10, #1
    b.ne .fail

    adr x9, status_null
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
