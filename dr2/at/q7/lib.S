.text
.global sqrt_nr
.type sqrt_nr, %function

sqrt_nr:
    fmov d2, xzr
    fcmp d0, d2
    b.lt .bad_input

    cbz w0, .bad_iter

    fmov d4, d0
    fmov d3, #1.0
    fcmp d0, d3
    b.ge .use_a_as_guess

    fmov d2, d3
    b .loop_setup

.use_a_as_guess:
    fmov d2, d0

.loop_setup:
    mov w2, w0
    fmov d5, #0.5

.loop:
    fdiv d6, d4, d2
    fadd d2, d2, d6
    fmul d2, d2, d5
    subs w2, w2, #1
    b.ne .loop

    fmov d0, d2
    mov w1, wzr
    ret

.bad_input:
    fmov d0, xzr
    mov w1, #1
    ret

.bad_iter:
    fmov d0, xzr
    mov w1, #2
    ret

.section .note.GNU-stack,"",@progbits
