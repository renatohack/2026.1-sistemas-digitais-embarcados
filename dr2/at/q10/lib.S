.text
.global moving_avg_i32
.type moving_avg_i32, %function

moving_avg_i32:
    cbz x0, .null_ptr
    cbz x1, .null_ptr
    cbz x2, .zero_len
    cbz w3, .bad_window

    uxtw x6, w3
    cmp x6, x2
    b.hi .bad_window

    mov x4, xzr
    mov x5, xzr
    sub w7, w3, #1
    uxtw x7, w7

.loop:
    cmp x4, x2
    b.ge .done

    add x8, x0, x4, lsl #2
    ldr w9, [x8]
    sxtw x9, w9
    add x5, x5, x9

    cmp x4, x6
    b.lt .no_sub
    sub x10, x4, x6
    add x11, x0, x10, lsl #2
    ldr w12, [x11]
    sxtw x12, w12
    sub x5, x5, x12

.no_sub:
    add x13, x1, x4, lsl #2
    cmp x4, x7
    b.lt .store_zero

    sdiv x14, x5, x6
    str w14, [x13]
    b .next

.store_zero:
    str wzr, [x13]

.next:
    add x4, x4, #1
    b .loop

.done:
    mov w0, wzr
    ret

.null_ptr:
    mov w0, #1
    ret

.zero_len:
    mov w0, #2
    ret

.bad_window:
    mov w0, #3
    ret

.section .note.GNU-stack,"",@progbits
