.text
.global poly_horner_q16_sat
.type poly_horner_q16_sat, %function

poly_horner_q16_sat:
    cbz x0, .null_ptr
    cbz x1, .bad_n

    mov x9, x1
    ldr w3, [x0], #4
    sxtw x3, w3
    sxtw x2, w2
    mov w8, wzr

    mov w4, #0x7fffffff
    sxtw x4, w4
    mov w5, #0x80000000
    sxtw x5, w5

    subs x9, x9, #1
    b.eq .done

.loop:
    ldr w6, [x0], #4
    sxtw x6, w6
    mul x7, x3, x2
    asr x7, x7, #16
    add x7, x7, x6

    cmp x7, x4
    b.gt .sat_max
    cmp x7, x5
    b.lt .sat_min

    mov x3, x7
    b .next

.sat_max:
    mov x3, x4
    mov w8, #3
    b .next

.sat_min:
    mov x3, x5
    mov w8, #3

.next:
    subs x9, x9, #1
    b.ne .loop

.done:
    mov w0, w3
    mov w1, w8
    ret

.bad_n:
    mov w0, wzr
    mov w1, #2
    ret

.null_ptr:
    mov w0, wzr
    mov w1, #1
    ret

.section .note.GNU-stack,"",@progbits
