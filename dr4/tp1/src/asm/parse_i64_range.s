.text
.align 2

.equ TP1_OK, 0
.equ TP1_ERR_INVALID, 2
.equ TP1_ERR_OVERFLOW, 3
.equ TP1_ERR_OUT_OF_RANGE, 4

.global parse_i64_range
.type parse_i64_range, %function
parse_i64_range:
    stp x29, x30, [sp, #-16]!
    mov x29, sp

    bl parse_i64
    cmp w0, #TP1_OK
    b.ne .map_error

    ldr x2, [x1]
    mov x3, #1000
    neg x4, x3
    cmp x2, x4
    b.lt .range_error
    cmp x2, x3
    b.gt .range_error

    mov w0, #TP1_OK
    ldp x29, x30, [sp], #16
    ret

.map_error:
    cmp w0, #TP1_ERR_OVERFLOW
    b.eq .range_error
    mov w0, #TP1_ERR_INVALID
    ldp x29, x30, [sp], #16
    ret

.range_error:
    mov w0, #TP1_ERR_OUT_OF_RANGE
    ldp x29, x30, [sp], #16
    ret
.size parse_i64_range, . - parse_i64_range
