.data
input_samples:
    .hword 32767, -32768, 1234, -20000, 0
.balign 4
output_samples:
    .word 0, 0, 0, 0, 0
expected_samples:
    .word 8388607, -8388608, 617000, -8388608, 0
status_primary:
    .word 0
status_zero:
    .word 0
status_null:
    .word 0
dummy_out:
    .word 0

.text
.global _start

_start:
    adr x0, input_samples
    adr x1, output_samples
    mov x2, #5
    mov w3, #500
    bl normalize_saturate_i16_to_i32
after_extreme_case:
    adr x9, status_primary
    str w0, [x9]

    adr x0, input_samples
    adr x1, dummy_out
    mov x2, #0
    mov w3, #3
    bl normalize_saturate_i16_to_i32
after_zero_case:
    adr x9, status_zero
    str w0, [x9]

    mov x0, xzr
    adr x1, dummy_out
    mov x2, #1
    mov w3, #1
    bl normalize_saturate_i16_to_i32
after_null_case:
    adr x9, status_null
    str w0, [x9]

    adr x10, output_samples
    adr x11, expected_samples
    mov x12, #5

.check_loop:
    ldr w13, [x10], #4
    ldr w14, [x11], #4
    cmp w13, w14
    b.ne .fail
    subs x12, x12, #1
    b.ne .check_loop

    adr x9, status_primary
    ldr w10, [x9]
    cmp w10, #0
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
