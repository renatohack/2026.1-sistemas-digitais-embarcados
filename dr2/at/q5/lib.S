.text
.global convert_speed_q16
.type convert_speed_q16, %function

convert_speed_q16:
    cmp w0, #0
    b.eq .kmh_to_ms
    cmp w0, #1
    b.eq .ms_to_kmh
    cmp w0, #2
    b.eq .knots_to_ms

    mov w0, wzr
    mov w2, #1
    ret

.kmh_to_ms:
    uxtw x3, w1
    mov x4, #1000
    mul x5, x3, x4
    mov x6, #3600
    udiv x5, x5, x6
    mov w0, w5
    mov w2, wzr
    ret

.ms_to_kmh:
    uxtw x3, w1
    mov x4, #3600
    mul x5, x3, x4
    mov x6, #1000
    udiv x5, x5, x6
    mov w0, w5
    mov w2, wzr
    ret

.knots_to_ms:
    uxtw x3, w1
    mov x4, #1852
    mul x5, x3, x4
    mov x6, #3600
    udiv x5, x5, x6
    mov w0, w5
    mov w2, wzr
    ret

.section .note.GNU-stack,"",@progbits
