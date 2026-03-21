.text
.global sin_taylor
.type sin_taylor, %function

sin_taylor:
    fmov d2, xzr
    fcmp d1, d2
    b.le .bad_eps

    cbz w0, .bad_iter

    fmov d2, d0
    fmov d3, d0
    fmul d4, d0, d0
    mov w2, wzr

    fabs d5, d3
    fcmp d5, d1
    b.lt .done

.loop:
    add w2, w2, #1
    cmp w2, w0
    b.ge .done

    lsl w5, w2, #1
    add w6, w5, #1
    scvtf d5, w5
    scvtf d6, w6

    fmul d3, d3, d4
    fneg d3, d3
    fdiv d3, d3, d5
    fdiv d3, d3, d6
    fadd d2, d2, d3

    fabs d7, d3
    fcmp d7, d1
    b.ge .loop

.done:
    fmov d0, d2
    mov w1, wzr
    ret

.bad_eps:
    fmov d0, xzr
    mov w1, #1
    ret

.bad_iter:
    fmov d0, xzr
    mov w1, #2
    ret

.section .note.GNU-stack,"",@progbits
