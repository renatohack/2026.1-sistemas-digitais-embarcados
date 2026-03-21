.text
.global trapz_energy_f64
.type trapz_energy_f64, %function

trapz_energy_f64:
    cbz x0, .null_ptr
    cmp x1, #2
    b.lt .bad_n

    fmov d1, xzr
    fcmp d0, d1
    b.le .bad_dt

    mov x2, x0
    sub x3, x1, #1
    ldr d2, [x2]
    fmov d3, xzr
    fmov d1, #0.5

.loop:
    ldr d4, [x2, #8]
    fadd d5, d2, d4
    fmul d5, d5, d0
    fmul d5, d5, d1
    fadd d3, d3, d5
    fmov d2, d4
    add x2, x2, #8
    subs x3, x3, #1
    b.ne .loop

    fmov d0, d3
    mov w0, wzr
    ret

.null_ptr:
    fmov d0, xzr
    mov w0, #1
    ret

.bad_n:
    fmov d0, xzr
    mov w0, #2
    ret

.bad_dt:
    fmov d0, xzr
    mov w0, #3
    ret

.section .note.GNU-stack,"",@progbits
