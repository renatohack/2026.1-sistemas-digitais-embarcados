.text
.global dot_i32_checked
.type dot_i32_checked, %function

dot_i32_checked:
    cbz x0, .null_ptr
    cbz x1, .null_ptr
    cbz x2, .zero_len

    mov x3, xzr

.loop:
    ldr w4, [x0], #4
    ldr w5, [x1], #4
    smull x6, w4, w5
    adds x7, x3, x6
    b.vs .overflow
    mov x3, x7
    subs x2, x2, #1
    b.ne .loop

    mov x0, x3
    mov w1, wzr
    ret

.overflow:
    mov x0, x3
    mov w1, #3
    ret

.zero_len:
    mov x0, xzr
    mov w1, #1
    ret

.null_ptr:
    mov x0, xzr
    mov w1, #2
    ret

.section .note.GNU-stack,"",@progbits
