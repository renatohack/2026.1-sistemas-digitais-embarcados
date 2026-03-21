.data
result_mode0:
    .word 0
result_mode1:
    .word 0
result_mode2:
    .word 0
result_invalid:
    .word 0
status_mode0:
    .word 0
status_mode1:
    .word 0
status_mode2:
    .word 0
status_invalid:
    .word 0

.text
.global _start

_start:
    mov w0, #0
    mov w1, #2359296
    bl convert_speed_q16
after_mode0:
    adr x9, result_mode0
    str w0, [x9]
    adr x9, status_mode0
    str w2, [x9]

    mov w0, #1
    mov w1, #655360
    bl convert_speed_q16
after_mode1:
    adr x9, result_mode1
    str w0, [x9]
    adr x9, status_mode1
    str w2, [x9]

    mov w0, #2
    mov w1, #235929600
    bl convert_speed_q16
after_mode2:
    adr x9, result_mode2
    str w0, [x9]
    adr x9, status_mode2
    str w2, [x9]

    mov w0, #99
    mov w1, #655360
    bl convert_speed_q16
after_invalid_mode:
    adr x9, result_invalid
    str w0, [x9]
    adr x9, status_invalid
    str w2, [x9]

    adr x9, result_mode0
    ldr w10, [x9]
    mov w11, #655360
    cmp w10, w11
    b.ne .fail

    adr x9, status_mode0
    ldr w10, [x9]
    cbnz w10, .fail

    adr x9, result_mode1
    ldr w10, [x9]
    mov w11, #2359296
    cmp w10, w11
    b.ne .fail

    adr x9, status_mode1
    ldr w10, [x9]
    cbnz w10, .fail

    adr x9, result_mode2
    ldr w10, [x9]
    mov w11, #121372672
    cmp w10, w11
    b.ne .fail

    adr x9, status_mode2
    ldr w10, [x9]
    cbnz w10, .fail

    adr x9, result_invalid
    ldr w10, [x9]
    cbnz w10, .fail

    adr x9, status_invalid
    ldr w10, [x9]
    cmp w10, #1
    b.ne .fail

    mov w0, wzr
    b .exit

.fail:
    mov w0, #1

.exit:
    mov x8, #93
    svc #0

.section .note.GNU-stack,"",@progbits
