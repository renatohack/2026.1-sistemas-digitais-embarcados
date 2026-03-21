.data
.balign 8
signal:
    .double 0.0, 1.0, 2.0
dt_one:
    .double 1.0
dt_zero:
    .double 0.0
expected_integral:
    .double 2.0
tol:
    .double 0.000001
result_ok:
    .double 0.0
result_bad_n:
    .double 0.0
result_bad_dt:
    .double 0.0
result_null:
    .double 0.0
.balign 4
status_ok:
    .word 0
status_bad_n:
    .word 0
status_bad_dt:
    .word 0
status_null:
    .word 0

.text
.global _start

_start:
    adr x0, signal
    mov x1, #3
    adr x9, dt_one
    ldr d0, [x9]
    bl trapz_energy_f64
after_primary_case:
    adr x10, result_ok
    str d0, [x10]
    adr x10, status_ok
    str w0, [x10]

    adr x0, signal
    mov x1, #1
    adr x9, dt_one
    ldr d0, [x9]
    bl trapz_energy_f64
after_bad_n_case:
    adr x10, result_bad_n
    str d0, [x10]
    adr x10, status_bad_n
    str w0, [x10]

    adr x0, signal
    mov x1, #3
    adr x9, dt_zero
    ldr d0, [x9]
    bl trapz_energy_f64
after_bad_dt_case:
    adr x10, result_bad_dt
    str d0, [x10]
    adr x10, status_bad_dt
    str w0, [x10]

    mov x0, xzr
    mov x1, #3
    adr x9, dt_one
    ldr d0, [x9]
    bl trapz_energy_f64
after_null_case:
    adr x10, result_null
    str d0, [x10]
    adr x10, status_null
    str w0, [x10]

    adr x9, status_ok
    ldr w10, [x9]
    cbnz w10, .fail

    adr x9, result_ok
    ldr d0, [x9]
    adr x10, expected_integral
    ldr d1, [x10]
    fsub d2, d0, d1
    fabs d2, d2
    adr x11, tol
    ldr d3, [x11]
    fcmp d2, d3
    b.gt .fail

    adr x9, status_bad_n
    ldr w10, [x9]
    cmp w10, #2
    b.ne .fail

    adr x9, result_bad_n
    ldr d0, [x9]
    fabs d0, d0
    adr x10, tol
    ldr d1, [x10]
    fcmp d0, d1
    b.gt .fail

    adr x9, status_bad_dt
    ldr w10, [x9]
    cmp w10, #3
    b.ne .fail

    adr x9, result_bad_dt
    ldr d0, [x9]
    fabs d0, d0
    adr x10, tol
    ldr d1, [x10]
    fcmp d0, d1
    b.gt .fail

    adr x9, status_null
    ldr w10, [x9]
    cmp w10, #1
    b.ne .fail

    adr x9, result_null
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
