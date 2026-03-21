.data
a_matrix:
    .word 65536, 0, 0, 65536
b_vec:
    .word 65536, 65536
p_vec:
    .word 131072, 196608
out_mode0:
    .word 0, 0
out_mode1:
    .word 0, 0
out_invalid:
    .word 0, 0
expected_mode0:
    .word 131072, 196608
expected_mode1:
    .word 196608, 262144
status_mode0:
    .word 0
status_mode1:
    .word 0
status_invalid:
    .word 0

.text
.global _start

_start:
    mov w0, #0
    adr x1, a_matrix
    adr x2, b_vec
    adr x3, p_vec
    adr x4, out_mode0
    bl affine2d_q16
after_mode0_case:
    adr x9, status_mode0
    str w0, [x9]

    mov w0, #1
    adr x1, a_matrix
    adr x2, b_vec
    adr x3, p_vec
    adr x4, out_mode1
    bl affine2d_q16
after_mode1_case:
    adr x9, status_mode1
    str w0, [x9]

    mov w0, #99
    adr x1, a_matrix
    adr x2, b_vec
    adr x3, p_vec
    adr x4, out_invalid
    bl affine2d_q16
after_invalid_mode:
    adr x9, status_invalid
    str w0, [x9]

    adr x10, out_mode0
    adr x11, expected_mode0
    mov x12, #2

.check_mode0:
    ldr w13, [x10], #4
    ldr w14, [x11], #4
    cmp w13, w14
    b.ne .fail
    subs x12, x12, #1
    b.ne .check_mode0

    adr x10, out_mode1
    adr x11, expected_mode1
    mov x12, #2

.check_mode1:
    ldr w13, [x10], #4
    ldr w14, [x11], #4
    cmp w13, w14
    b.ne .fail
    subs x12, x12, #1
    b.ne .check_mode1

    adr x9, status_mode0
    ldr w10, [x9]
    cbnz w10, .fail

    adr x9, status_mode1
    ldr w10, [x9]
    cbnz w10, .fail

    adr x9, status_invalid
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
