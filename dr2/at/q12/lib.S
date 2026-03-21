.text
.global normalize_saturate_i16_to_i32
.global dot_i32_checked
.global safe_div_s64
.global sqrt_nr
.global classify_health

.type normalize_saturate_i16_to_i32, %function
normalize_saturate_i16_to_i32:
    cbz x0, .norm_null_ptr
    cbz x1, .norm_null_ptr
    cbz x2, .norm_zero_len

    mov x4, #-8388608
    mov x5, #8388607

.norm_loop:
    ldrsh w6, [x0], #2
    smull x7, w6, w3
    cmp x7, x4
    b.lt .norm_sat_min
    cmp x7, x5
    b.gt .norm_sat_max
    str w7, [x1], #4
    b .norm_next

.norm_sat_min:
    str w4, [x1], #4
    b .norm_next

.norm_sat_max:
    str w5, [x1], #4

.norm_next:
    subs x2, x2, #1
    b.ne .norm_loop

    mov w0, wzr
    ret

.norm_zero_len:
    mov w0, #1
    ret

.norm_null_ptr:
    mov w0, #2
    ret

.type dot_i32_checked, %function
dot_i32_checked:
    cbz x0, .dot_null_ptr
    cbz x1, .dot_null_ptr
    cbz x2, .dot_zero_len

    mov x3, xzr

.dot_loop:
    ldr w4, [x0], #4
    ldr w5, [x1], #4
    smull x6, w4, w5
    adds x7, x3, x6
    b.vs .dot_overflow
    mov x3, x7
    subs x2, x2, #1
    b.ne .dot_loop

    mov x0, x3
    mov w1, wzr
    ret

.dot_overflow:
    mov x0, x3
    mov w1, #3
    ret

.dot_zero_len:
    mov x0, xzr
    mov w1, #1
    ret

.dot_null_ptr:
    mov x0, xzr
    mov w1, #2
    ret

.type safe_div_s64, %function
safe_div_s64:
    cbz x1, .div_zero

    mov x2, #1
    lsl x2, x2, #63
    cmp x0, x2
    b.ne .do_div
    cmp x1, #-1
    b.ne .do_div

    mov x0, #-1
    lsr x0, x0, #1
    mov w1, #2
    ret

.do_div:
    sdiv x0, x0, x1
    mov w1, wzr
    ret

.div_zero:
    mov x0, #-1
    lsr x0, x0, #1
    mov w1, #1
    ret

.type sqrt_nr, %function
sqrt_nr:
    fmov d2, xzr
    fcmp d0, d2
    b.lt .sqrt_bad_input

    cbz w0, .sqrt_bad_iter

    fmov d4, d0
    fmov d3, #1.0
    fcmp d0, d3
    b.ge .sqrt_use_a

    fmov d2, d3
    b .sqrt_loop_setup

.sqrt_use_a:
    fmov d2, d0

.sqrt_loop_setup:
    mov w2, w0
    fmov d5, #0.5

.sqrt_loop:
    fdiv d6, d4, d2
    fadd d2, d2, d6
    fmul d2, d2, d5
    subs w2, w2, #1
    b.ne .sqrt_loop

    fmov d0, d2
    mov w1, wzr
    ret

.sqrt_bad_input:
    fmov d0, xzr
    mov w1, #1
    ret

.sqrt_bad_iter:
    fmov d0, xzr
    mov w1, #2
    ret

.type classify_health, %function
classify_health:
    mov w2, wzr
    cbnz w0, .class_fault
    fcmp d0, d1
    b.gt .class_degraded
    b .dispatch

.class_fault:
    mov w2, #2
    b .dispatch

.class_degraded:
    mov w2, #1

.dispatch:
    cmp w2, #0
    b.eq .ret_ok
    cmp w2, #1
    b.eq .ret_degraded
    mov w0, #2
    ret

.ret_ok:
    mov w0, wzr
    ret

.ret_degraded:
    mov w0, #1
    ret

.section .note.GNU-stack,"",@progbits
