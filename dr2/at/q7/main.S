.data
.balign 8
a_four:
    .double 4.0
a_neg:
    .double -1.0
expected_two:
    .double 2.0
tol:
    .double 0.000001
result_four:
    .double 0.0
result_neg:
    .double 0.0
result_zero_iter:
    .double 0.0
.balign 4
status_four:
    .word 0
status_neg:
    .word 0
status_zero_iter:
    .word 0

.text
.global _start

_start:
    adr x9, a_four
    ldr d0, [x9]
    mov w0, #8
    bl sqrt_nr
after_positive_case:
    adr x10, result_four
    str d0, [x10]
    adr x10, status_four
    str w1, [x10]

    adr x9, a_neg
    ldr d0, [x9]
    mov w0, #8
    bl sqrt_nr
after_negative_case:
    adr x10, result_neg
    str d0, [x10]
    adr x10, status_neg
    str w1, [x10]

    adr x9, a_four
    ldr d0, [x9]
    mov w0, wzr
    bl sqrt_nr
after_zero_iter_case:
    adr x10, result_zero_iter
    str d0, [x10]
    adr x10, status_zero_iter
    str w1, [x10]

    adr x9, status_four
    ldr w10, [x9]
    cbnz w10, .fail

    adr x9, result_four
    ldr d0, [x9]
    adr x10, expected_two
    ldr d1, [x10]
    fsub d2, d0, d1
    fabs d2, d2
    adr x11, tol
    ldr d3, [x11]
    fcmp d2, d3
    b.gt .fail

    adr x9, status_neg
    ldr w10, [x9]
    cmp w10, #1
    b.ne .fail

    adr x9, result_neg
    ldr d0, [x9]
    fabs d0, d0
    adr x10, tol
    ldr d1, [x10]
    fcmp d0, d1
    b.gt .fail

    adr x9, status_zero_iter
    ldr w10, [x9]
    cmp w10, #2
    b.ne .fail

    adr x9, result_zero_iter
    ldr d0, [x9]
    fabs d0, d0
    adr x10, tol
    ldr d1, [x10]
    fcmp d0, d1
    b.gt .fail

    mov w0, wzr
    b .exit

.fail:
    mov w0, #1

.exit:
    mov x8, #93
    svc #0

.section .note.GNU-stack,"",@progbits
