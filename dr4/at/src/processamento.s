    .arch armv8-a+simd
    .text

    .global process_metrics
    .type process_metrics, %function
process_metrics:
    adrp x0, values
    add x0, x0, :lo12:values
    adrp x1, status
    add x1, x1, :lo12:status
    mov x2, #8
    mov x3, #0
    mov x4, #0
    mov x5, #0
    mov x6, #0
    mov x7, #0

1:
    ldr w8, [x0], #4
    ldrb w9, [x1], #1
    tst w9, #0x1
    b.eq 2f
    add x3, x3, #1
    add x4, x4, x8
2:
    tst w9, #0x4
    cinc x5, x5, ne
    tst w9, #0x8
    cinc x6, x6, ne
    tst w9, #0x1
    cinc x7, x7, eq
    subs x2, x2, #1
    b.ne 1b

    udiv x10, x4, x3

    adrp x11, valid_count_result
    add x11, x11, :lo12:valid_count_result
    str x3, [x11]
    adrp x11, valid_sum_result
    add x11, x11, :lo12:valid_sum_result
    str x4, [x11]
    adrp x11, valid_avg_result
    add x11, x11, :lo12:valid_avg_result
    str x10, [x11]
    adrp x11, alarm_count_result
    add x11, x11, :lo12:alarm_count_result
    str x5, [x11]
    adrp x11, battery_count_result
    add x11, x11, :lo12:battery_count_result
    str x6, [x11]
    adrp x11, invalid_count_result
    add x11, x11, :lo12:invalid_count_result
    str x7, [x11]

    and x12, x3, #0xf
    and x13, x5, #0xf
    lsl x13, x13, #4
    orr x12, x12, x13
    and x13, x6, #0xf
    lsl x13, x13, #8
    orr x12, x12, x13
    and x13, x7, #0xf
    lsl x13, x13, #12
    orr x12, x12, x13
    bic x12, x12, #0xffff0000

    lsl x13, x12, #5
    lsr x14, x12, #11
    orr x13, x13, x14
    and x13, x13, #0xffff

    mov x15, #0xffff
    bic x16, x15, x12
    eor x14, x12, x13
    and x14, x14, #0xffff

    adrp x11, status_word_result
    add x11, x11, :lo12:status_word_result
    str x12, [x11]
    adrp x11, status_rotl_result
    add x11, x11, :lo12:status_rotl_result
    str x13, [x11]
    adrp x11, status_signature_result
    add x11, x11, :lo12:status_signature_result
    str x14, [x11]

    mov x0, x3
    mov x1, x4
    mov x2, x10
    mov x3, x5
    mov x4, x6
    mov x5, x12
    mov x6, x14
    .global metrics_done
metrics_done:
    ret
    .size process_metrics, .-process_metrics

    .global convert_valid_values_lut
    .type convert_valid_values_lut, %function
convert_valid_values_lut:
    adrp x0, values
    add x0, x0, :lo12:values
    adrp x1, status
    add x1, x1, :lo12:status
    adrp x2, lut_values
    add x2, x2, :lo12:lut_values
    adrp x3, lut_output_values
    add x3, x3, :lo12:lut_output_values
    mov x4, #8
    mov x5, #0
    mov x6, #0
    mov w10, #10

3:
    ldr w7, [x0], #4
    ldrb w8, [x1], #1
    tst w8, #0x1
    b.eq 4f
    udiv w9, w7, w10
    sub w9, w9, #1
    ldr w11, [x2, w9, uxtw #2]
    str w11, [x3], #4
    add x5, x5, #1
    add x6, x6, x11
4:
    subs x4, x4, #1
    b.ne 3b

    adrp x12, lut_count_result
    add x12, x12, :lo12:lut_count_result
    str x5, [x12]
    adrp x12, lut_sum_result
    add x12, x12, :lo12:lut_sum_result
    str x6, [x12]

    mov x0, x5
    mov x1, x6
    .global lut_done
lut_done:
    ret
    .size convert_valid_values_lut, .-convert_valid_values_lut

    .global sum_first_four_neon
    .type sum_first_four_neon, %function
sum_first_four_neon:
    adrp x0, values
    add x0, x0, :lo12:values
    ldr q0, [x0]
    addv s1, v0.4s
    fmov w0, s1
    adrp x1, neon_sum4_result
    add x1, x1, :lo12:neon_sum4_result
    str x0, [x1]
    .global neon_int_done
neon_int_done:
    ret
    .size sum_first_four_neon, .-sum_first_four_neon

    .global normalize_lut_f32_neon
    .type normalize_lut_f32_neon, %function
normalize_lut_f32_neon:
    adrp x0, lut_first4_f32
    add x0, x0, :lo12:lut_first4_f32
    adrp x1, f32_divisor_1000
    add x1, x1, :lo12:f32_divisor_1000
    adrp x2, normalized_values
    add x2, x2, :lo12:normalized_values
    ldr q0, [x0]
    ldr q1, [x1]
    fdiv v2.4s, v0.4s, v1.4s
    str q2, [x2]
    .global neon_float_done
neon_float_done:
    ret
    .size normalize_lut_f32_neon, .-normalize_lut_f32_neon

    .data
    .balign 16
    .global values
values:
    .word 10, 20, 30, 40, 50, 60, 70, 80

    .global status
status:
    .byte 0x01, 0x01, 0x05, 0x01, 0x09, 0x01, 0x00, 0x01

    .balign 16
lut_values:
    .word 100, 200, 300, 400, 500, 600, 700, 800

    .balign 16
lut_first4_f32:
    .float 100.0, 200.0, 300.0, 400.0

    .balign 16
f32_divisor_1000:
    .float 1000.0, 1000.0, 1000.0, 1000.0

    .bss
    .balign 16
    .global valid_count_result
valid_count_result:
    .skip 8
    .global valid_sum_result
valid_sum_result:
    .skip 8
    .global valid_avg_result
valid_avg_result:
    .skip 8
    .global alarm_count_result
alarm_count_result:
    .skip 8
    .global battery_count_result
battery_count_result:
    .skip 8
    .global invalid_count_result
invalid_count_result:
    .skip 8
    .global status_word_result
status_word_result:
    .skip 8
    .global status_rotl_result
status_rotl_result:
    .skip 8
    .global status_signature_result
status_signature_result:
    .skip 8
    .global lut_count_result
lut_count_result:
    .skip 8
    .global lut_sum_result
lut_sum_result:
    .skip 8
    .global neon_sum4_result
neon_sum4_result:
    .skip 8
    .balign 16
    .global lut_output_values
lut_output_values:
    .skip 32
    .balign 16
    .global normalized_values
normalized_values:
    .skip 16
