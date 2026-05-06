.text
.align 2

.global u64_to_str
.type u64_to_str, %function
u64_to_str:
    cbz x2, .buffer_error
    cbz x1, .buffer_error

    stp x29, x30, [sp, #-48]!
    mov x29, sp

    add x3, sp, #16
    mov x4, #0
    mov x5, x0
    mov x6, #10

    cbnz x5, .convert_loop
    mov w7, #'0'
    strb w7, [x3]
    mov x4, #1
    b .digits_ready

.convert_loop:
    udiv x7, x5, x6
    msub x8, x7, x6, x5
    add w8, w8, #'0'
    strb w8, [x3, x4]
    add x4, x4, #1
    mov x5, x7
    cbnz x5, .convert_loop

.digits_ready:
    add x9, x4, #1
    cmp x9, x2
    b.hi .buffer_too_small

    mov x10, #0
.copy_loop:
    cmp x10, x4
    b.hs .finish
    sub x11, x4, x10
    sub x11, x11, #1
    ldrb w12, [x3, x11]
    strb w12, [x1, x10]
    add x10, x10, #1
    b .copy_loop

.finish:
    strb wzr, [x1, x4]
    mov x0, x4
    ldp x29, x30, [sp], #48
    ret

.buffer_too_small:
    strb wzr, [x1]
    mov x0, #0
    ldp x29, x30, [sp], #48
    ret

.buffer_error:
    mov x0, #0
    ret
.size u64_to_str, . - u64_to_str
