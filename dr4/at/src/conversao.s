    .text

    .global strlen_ascii
    .type strlen_ascii, %function
strlen_ascii:
    mov x1, x0
1:
    ldrb w2, [x1], #1
    cbnz w2, 1b
    sub x0, x1, x0
    sub x0, x0, #1
    ret
    .size strlen_ascii, .-strlen_ascii

    .global u64_to_ascii
    .type u64_to_ascii, %function
u64_to_ascii:
    cmp x2, #2
    b.lo 9f
    mov x3, x1
    mov x4, x0
    cbnz x4, 1f
    mov w5, #'0'
    strb w5, [x3]
    strb wzr, [x3, #1]
    mov x0, #1
    ret

1:
    add x5, x1, x2
    sub x5, x5, #1
    strb wzr, [x5]
    mov x6, #0
    mov x7, #10
2:
    cbz x4, 3f
    cmp x6, x2
    b.hs 9f
    udiv x8, x4, x7
    msub x9, x8, x7, x4
    add w9, w9, #'0'
    sub x5, x5, #1
    strb w9, [x5]
    mov x4, x8
    add x6, x6, #1
    b 2b

3:
    mov x10, #0
4:
    cmp x10, x6
    b.hs 5f
    ldrb w11, [x5, x10]
    strb w11, [x3, x10]
    add x10, x10, #1
    b 4b
5:
    strb wzr, [x3, x6]
    mov x0, x6
    ret

9:
    mov x0, #0
    ret
    .size u64_to_ascii, .-u64_to_ascii

    .global u64_to_hex_fixed
    .type u64_to_hex_fixed, %function
u64_to_hex_fixed:
    cbz x2, 8f
    cmp x2, #16
    b.hi 8f
    mov x3, #0
    lsl x4, x2, #2
    sub x4, x4, #4
1:
    lsr x5, x0, x4
    and x5, x5, #0xf
    cmp x5, #10
    b.lo 2f
    add w5, w5, #('a' - 10)
    b 3f
2:
    add w5, w5, #'0'
3:
    strb w5, [x1, x3]
    add x3, x3, #1
    cbz x4, 4f
    sub x4, x4, #4
    b 1b
4:
    strb wzr, [x1, x3]
    mov x0, x3
    ret
8:
    mov x0, #0
    ret
    .size u64_to_hex_fixed, .-u64_to_hex_fixed

    .global parse_u64_checked
    .type parse_u64_checked, %function
parse_u64_checked:
    mov x2, x0
    mov x3, x1
    mov x4, #0
    mov x9, #0
    ldrb w5, [x2]
    cbz w5, 9f
    cmp w5, #'-'
    b.eq 9f
    cmp w5, #'+'
    b.eq 9f

1:
    ldrb w5, [x2], #1
    cbz w5, 5f
    cmp w5, #'0'
    b.lo 9f
    cmp w5, #'9'
    b.hi 9f
    sub x5, x5, #'0'
    add x9, x9, #1
    sub x6, x3, x5
    mov x7, #10
    udiv x6, x6, x7
    cmp x4, x6
    b.hi 9f
    madd x4, x4, x7, x5
    b 1b

5:
    cbz x9, 9f
    mov x0, #1
    mov x1, x4
    ret

9:
    mov x0, #0
    mov x1, #0
    ret
    .size parse_u64_checked, .-parse_u64_checked
