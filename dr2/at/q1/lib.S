.text
.global normalize_saturate_i16_to_i32
.type normalize_saturate_i16_to_i32, %function

normalize_saturate_i16_to_i32:
    cbz x0, .null_ptr
    cbz x1, .null_ptr
    cbz x2, .zero_len

    mov x4, #-8388608
    mov x5, #8388607

.loop:
    ldrsh w6, [x0], #2
    smull x7, w6, w3
    cmp x7, x4
    b.lt .sat_min
    cmp x7, x5
    b.gt .sat_max
    str w7, [x1], #4
    b .next

.sat_min:
    str w4, [x1], #4
    b .next

.sat_max:
    str w5, [x1], #4

.next:
    subs x2, x2, #1
    b.ne .loop

    mov w0, wzr
    ret

.zero_len:
    mov w0, #1
    ret

.null_ptr:
    mov w0, #2
    ret

.section .note.GNU-stack,"",@progbits
