.data
input_vec:
    .word 1, 2, 3, 4
output_vec:
    .word 0, 0, 0, 0
expected_vec:
    .word 0, 1, 2, 3
status_ok:
    .word 0
status_bad_w:
    .word 0
status_bad_n:
    .word 0
status_null:
    .word 0

.text
.global _start

_start:
    adr x0, input_vec
    adr x1, output_vec
    mov x2, #4
    mov w3, #2
    bl moving_avg_i32
after_primary_case:
    adr x9, status_ok
    str w0, [x9]

    adr x0, input_vec
    adr x1, output_vec
    mov x2, #4
    mov w3, wzr
    bl moving_avg_i32
after_bad_w_case:
    adr x9, status_bad_w
    str w0, [x9]

    adr x0, input_vec
    adr x1, output_vec
    mov x2, xzr
    mov w3, #2
    bl moving_avg_i32
after_bad_n_case:
    adr x9, status_bad_n
    str w0, [x9]

    mov x0, xzr
    adr x1, output_vec
    mov x2, #4
    mov w3, #2
    bl moving_avg_i32
after_null_case:
    adr x9, status_null
    str w0, [x9]

    adr x10, output_vec
    adr x11, expected_vec
    mov x12, #4

.check_loop:
    ldr w13, [x10], #4
    ldr w14, [x11], #4
    cmp w13, w14
    b.ne .fail
    subs x12, x12, #1
    b.ne .check_loop

    adr x9, status_ok
    ldr w10, [x9]
    cbnz w10, .fail

    adr x9, status_bad_w
    ldr w10, [x9]
    cmp w10, #3
    b.ne .fail

    adr x9, status_bad_n
    ldr w10, [x9]
    cmp w10, #2
    b.ne .fail

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
