    .text

    .global ex1_lookup_byte_byte
    .type ex1_lookup_byte_byte, %function
ex1_lookup_byte_byte:
    adrp x1, ex1_table
    add x1, x1, :lo12:ex1_table
    uxtb w0, w0
    ldrb w0, [x1, x0]
    ret

    .global ex2_lookup_byte_halfword
    .type ex2_lookup_byte_halfword, %function
ex2_lookup_byte_halfword:
    adrp x1, ex2_table
    add x1, x1, :lo12:ex2_table
    uxtb w0, w0
    ldrh w0, [x1, w0, uxtw #1]
    ret

    .global ex3_lookup_word_byte
    .type ex3_lookup_word_byte, %function
ex3_lookup_word_byte:
    adrp x1, ex3_table
    add x1, x1, :lo12:ex3_table
    uxtb w0, w0
    ldrb w0, [x1, x0]
    ret

    .global ex4_lookup_word_word
    .type ex4_lookup_word_word, %function
ex4_lookup_word_word:
    adrp x1, ex4_table
    add x1, x1, :lo12:ex4_table
    uxtb w0, w0
    ldr w0, [x1, w0, uxtw #2]
    ret

    .global ex5_clear_bits_bic
    .type ex5_clear_bits_bic, %function
ex5_clear_bits_bic:
    bic x0, x0, x1
    ret

    .global ex6_set_bits_orr
    .type ex6_set_bits_orr, %function
ex6_set_bits_orr:
    orr x0, x0, x1
    ret

    .global ex7_toggle_bits_eor
    .type ex7_toggle_bits_eor, %function
ex7_toggle_bits_eor:
    eor x0, x0, x1
    ret

    .global ex8_test_bits_status
    .type ex8_test_bits_status, %function
ex8_test_bits_status:
    ands xzr, x0, x1
    cset w0, ne
    ret

    .global ex9_extract_field
    .type ex9_extract_field, %function
ex9_extract_field:
    cbz x2, ex9_zero_width
    cmp x2, #64
    b.hs ex9_full_width
    mov x3, #1
    lsl x3, x3, x2
    sub x3, x3, #1
    lsr x0, x0, x1
    and x0, x0, x3
    ret
ex9_zero_width:
    mov x0, #0
    ret
ex9_full_width:
    lsr x0, x0, x1
    ret

    .global ex10_insert_field
    .type ex10_insert_field, %function
ex10_insert_field:
    cbz x3, ex10_done
    cmp x3, #64
    b.hs ex10_replace_all
    mov x4, #1
    lsl x4, x4, x3
    sub x4, x4, #1
    and x1, x1, x4
    lsl x5, x1, x2
    lsl x6, x4, x2
    bic x0, x0, x6
    orr x0, x0, x5
    ret
ex10_replace_all:
    mov x0, x1
    ret
ex10_done:
    ret

    .global ex11_rotate_left_manual
    .type ex11_rotate_left_manual, %function
ex11_rotate_left_manual:
    and x1, x1, #63
    neg x2, x1
    and x2, x2, #63
    lsl x3, x0, x1
    lsr x4, x0, x2
    orr x0, x3, x4
    ret

    .global ex12_pipeline
    .type ex12_pipeline, %function
ex12_pipeline:
    mov x1, x0
    lsr x2, x0, #12
    and x2, x2, #0xf

    adrp x3, ex12_table
    add x3, x3, :lo12:ex12_table
    ldrb w4, [x3, x2]

    and x4, x4, #0x3f
    lsl x4, x4, #20

    mov x5, #0x3f
    lsl x5, x5, #20
    bic x0, x1, x5
    orr x0, x0, x4

    movz x6, #0x0100, lsl #32
    orr x0, x0, x6
    ret

    .section .rodata
    .balign 16

ex1_table:
    .set ex1_i, 0
    .rept 256
    .byte ((ex1_i * 73 + 41) & 0xff)
    .set ex1_i, ex1_i + 1
    .endr

    .balign 16
ex2_table:
    .set ex2_i, 0
    .rept 256
    .hword ((0x1200 + ex2_i * 257) & 0xffff)
    .set ex2_i, ex2_i + 1
    .endr

    .balign 16
ex3_table:
    .set ex3_i, 0
    .rept 256
    .byte (ex3_i ^ 0xa5)
    .set ex3_i, ex3_i + 1
    .endr

    .balign 16
ex4_table:
    .set ex4_i, 0
    .rept 256
    .word ((0xa5000000 + ex4_i * 0x01010101) & 0xffffffff)
    .set ex4_i, ex4_i + 1
    .endr

    .balign 16
ex12_table:
    .set ex12_i, 0
    .rept 16
    .byte ((0x12 + ex12_i * 11) & 0xff)
    .set ex12_i, ex12_i + 1
    .endr
