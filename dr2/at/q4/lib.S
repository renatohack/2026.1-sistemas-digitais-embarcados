.text
.global safe_div_s64
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

.section .note.GNU-stack,"",@progbits
