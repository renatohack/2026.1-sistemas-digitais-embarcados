.data
samples_i16:
    .hword 32767, -32768, 1000, -1000
.balign 4
normalized_i32:
    .word 0, 0, 0, 0
expected_normalized:
    .word 8388607, -8388608, 500000, -500000
.balign 8
energy_value:
    .quad 0
expected_energy:
    .quad 141237471578113
mean_value:
    .quad 0
expected_mean:
    .quad 35309367894528
.balign 8
magnitude_value:
    .double 0.0
expected_magnitude:
    .double 5942168.618823266
magnitude_tol:
    .double 0.001
threshold_value:
    .double 1000000.0
.balign 4
normalize_status:
    .word 0
dot_status:
    .word 0
div_status:
    .word 0
sqrt_status:
    .word 0
flags_value:
    .word 0
final_code:
    .word 0

.text
.global _start

_start:
    mov w19, wzr

    adr x0, samples_i16
    adr x1, normalized_i32
    mov x2, #4
    mov w3, #500
    bl normalize_saturate_i16_to_i32
after_normalize:
    adr x9, normalize_status
    str w0, [x9]
    cmp w0, #2
    b.ne .check_norm_n
    orr w19, w19, #1
    b .scan_saturation

.check_norm_n:
    cmp w0, #1
    b.ne .scan_saturation
    orr w19, w19, #2

.scan_saturation:
    adr x10, normalized_i32
    mov x11, #4
    mov w12, #8388607
    mov w13, #0xFF800000

.scan_loop:
    ldr w14, [x10], #4
    cmp w14, w12
    b.eq .mark_fault
    cmp w14, w13
    b.eq .mark_fault
    b .scan_next

.mark_fault:
    orr w19, w19, #8

.scan_next:
    subs x11, x11, #1
    b.ne .scan_loop

    adr x0, normalized_i32
    adr x1, normalized_i32
    mov x2, #4
    bl dot_i32_checked
after_dot:
    adr x9, energy_value
    str x0, [x9]
    adr x9, dot_status
    str w1, [x9]
    cmp w1, #2
    b.ne .check_dot_n
    orr w19, w19, #1
    b .divide_energy

.check_dot_n:
    cmp w1, #1
    b.ne .check_dot_overflow
    orr w19, w19, #2
    b .divide_energy

.check_dot_overflow:
    cmp w1, #3
    b.ne .divide_energy
    orr w19, w19, #8

.divide_energy:
    mov x1, #4
    bl safe_div_s64
after_divide:
    adr x9, mean_value
    str x0, [x9]
    adr x9, div_status
    str w1, [x9]
    cmp w1, wzr
    b.eq .compute_sqrt
    orr w19, w19, #4

.compute_sqrt:
    scvtf d0, x0
    mov w0, #40
    bl sqrt_nr
after_sqrt:
    adr x9, magnitude_value
    str d0, [x9]
    adr x9, sqrt_status
    str w1, [x9]
    cmp w1, wzr
    b.eq .classify
    orr w19, w19, #4

.classify:
    adr x9, flags_value
    str w19, [x9]
    mov w0, w19
    adr x10, threshold_value
    ldr d1, [x10]
    bl classify_health
after_classify:
    adr x9, final_code
    str w0, [x9]
    mov w20, w0

    adr x10, normalized_i32
    adr x11, expected_normalized
    mov x12, #4

.check_norm_loop:
    ldr w13, [x10], #4
    ldr w14, [x11], #4
    cmp w13, w14
    b.ne .validation_fail
    subs x12, x12, #1
    b.ne .check_norm_loop

    adr x9, normalize_status
    ldr w10, [x9]
    cbnz w10, .validation_fail

    adr x9, dot_status
    ldr w10, [x9]
    cbnz w10, .validation_fail

    adr x9, energy_value
    ldr x10, [x9]
    adr x11, expected_energy
    ldr x12, [x11]
    cmp x10, x12
    b.ne .validation_fail

    adr x9, div_status
    ldr w10, [x9]
    cbnz w10, .validation_fail

    adr x9, mean_value
    ldr x10, [x9]
    adr x11, expected_mean
    ldr x12, [x11]
    cmp x10, x12
    b.ne .validation_fail

    adr x9, sqrt_status
    ldr w10, [x9]
    cbnz w10, .validation_fail

    adr x9, magnitude_value
    ldr d0, [x9]
    adr x10, expected_magnitude
    ldr d1, [x10]
    fsub d2, d0, d1
    fabs d2, d2
    adr x11, magnitude_tol
    ldr d3, [x11]
    fcmp d2, d3
    b.gt .validation_fail

    adr x9, flags_value
    ldr w10, [x9]
    cmp w10, #8
    b.ne .validation_fail

    cmp w20, #2
    b.ne .validation_fail

    mov w0, w20
    b .exit

.validation_fail:
    mov w0, #255

.exit:
    mov x8, #93
    svc #0

.section .note.GNU-stack,"",@progbits
