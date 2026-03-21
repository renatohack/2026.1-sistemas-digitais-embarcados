.data
.balign 8
x_zero:
    .double 0.0
x_one:
    .double 1.0
eps_small:
    .double 0.000000000001
eps_zero:
    .double 0.0
expected_one:
    .double 0.8414709848078965
tol:
    .double 0.000001
result_zero:
    .double 0.0
result_one:
    .double 0.0
result_bad_eps:
    .double 0.0
result_bad_iter:
    .double 0.0
.balign 4
status_zero_case:
    .word 0
status_one_case:
    .word 0
status_bad_eps:
    .word 0
status_bad_iter:
    .word 0

.text
.global _start

_start:
    adr x9, x_zero
    ldr d0, [x9]
    adr x10, eps_small
    ldr d1, [x10]
    mov w0, #8
    bl sin_taylor
after_zero_case:
    adr x11, result_zero
    str d0, [x11]
    adr x11, status_zero_case
    str w1, [x11]

    adr x9, x_one
    ldr d0, [x9]
    adr x10, eps_small
    ldr d1, [x10]
    mov w0, #12
    bl sin_taylor
after_unit_case:
    adr x11, result_one
    str d0, [x11]
    adr x11, status_one_case
    str w1, [x11]

    adr x9, x_one
    ldr d0, [x9]
    adr x10, eps_zero
    ldr d1, [x10]
    mov w0, #12
    bl sin_taylor
after_bad_eps:
    adr x11, result_bad_eps
    str d0, [x11]
    adr x11, status_bad_eps
    str w1, [x11]

    adr x9, x_one
    ldr d0, [x9]
    adr x10, eps_small
    ldr d1, [x10]
    mov w0, wzr
    bl sin_taylor
after_bad_iter:
    adr x11, result_bad_iter
    str d0, [x11]
    adr x11, status_bad_iter
    str w1, [x11]

    adr x9, status_zero_case
    ldr w10, [x9]
    cmp w10, #0
    b.ne .fail

    adr x9, status_one_case
    ldr w10, [x9]
    cmp w10, #0
    b.ne .fail

    adr x9, status_bad_eps
    ldr w10, [x9]
    cmp w10, #1
    b.ne .fail

    adr x9, status_bad_iter
    ldr w10, [x9]
    cmp w10, #2
    b.ne .fail

    adr x9, result_zero
    ldr d0, [x9]
    fabs d0, d0
    adr x10, tol
    ldr d1, [x10]
    fcmp d0, d1
    b.gt .fail

    adr x9, result_one
    ldr d0, [x9]
    adr x10, expected_one
    ldr d1, [x10]
    fsub d2, d0, d1
    fabs d2, d2
    adr x11, tol
    ldr d3, [x11]
    fcmp d2, d3
    b.gt .fail

    adr x9, result_bad_eps
    ldr d0, [x9]
    fabs d0, d0
    adr x10, tol
    ldr d1, [x10]
    fcmp d0, d1
    b.gt .fail

    adr x9, result_bad_iter
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
