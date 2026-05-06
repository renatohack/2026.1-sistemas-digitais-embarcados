.text
.align 2

.equ TP1_OK, 0
.equ TP1_ERR_DIV_BY_ZERO, 5

.global int_div_to_double
.type int_div_to_double, %function
int_div_to_double:
    cmp x1, #0
    b.eq .div_by_zero

    scvtf d0, x0
    scvtf d1, x1
    fdiv d0, d0, d1
    cbz x2, .success
    str d0, [x2]

.success:
    mov w0, #TP1_OK
    ret

.div_by_zero:
    fmov d0, xzr
    cbz x2, .div_status
    str d0, [x2]

.div_status:
    mov w0, #TP1_ERR_DIV_BY_ZERO
    ret
.size int_div_to_double, . - int_div_to_double
