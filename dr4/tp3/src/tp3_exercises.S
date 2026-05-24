    .macro INIT_VEC_ZERO reg
        eor \reg\().16b, \reg\().16b, \reg\().16b
    .endm

    .macro SIMD_ADD16_U8_BLOCK dst, lhs, rhs, base_a, base_b, base_out, offset
        add x9, \base_a, #\offset
        add x10, \base_b, #\offset
        add x11, \base_out, #\offset
        ld1 {\lhs\().16b}, [x9]
        ld1 {\rhs\().16b}, [x10]
        add \dst\().16b, \lhs\().16b, \rhs\().16b
        st1 {\dst\().16b}, [x11]
    .endm

    .text

    .global ex1_move_w_to_low_u32
    .type ex1_move_w_to_low_u32, %function
ex1_move_w_to_low_u32:
    ldr q0, [x1]
    mov v0.s[0], w0
    .global ex1_after_insert
ex1_after_insert:
    str q0, [x2]
    ret
    .size ex1_move_w_to_low_u32, .-ex1_move_w_to_low_u32

    .global ex2_move_x_to_low_u64
    .type ex2_move_x_to_low_u64, %function
ex2_move_x_to_low_u64:
    ldr q0, [x1]
    mov v0.d[0], x0
    .global ex2_after_insert
ex2_after_insert:
    str q0, [x2]
    ret
    .size ex2_move_x_to_low_u64, .-ex2_move_x_to_low_u64

    .global ex3_zero_v0
    .type ex3_zero_v0, %function
ex3_zero_v0:
    movi v0.16b, #0xff
    eor v0.16b, v0.16b, v0.16b
    .global ex3_after_zero
ex3_after_zero:
    str q0, [x0]
    ret
    .size ex3_zero_v0, .-ex3_zero_v0

    .global ex4_fill_ones_v0
    .type ex4_fill_ones_v0, %function
ex4_fill_ones_v0:
    movi v0.16b, #0xff
    .global ex4_after_fill
ex4_after_fill:
    str q0, [x0]
    ret
    .size ex4_fill_ones_v0, .-ex4_fill_ones_v0

    .global ex5_shuffle_bytes
    .type ex5_shuffle_bytes, %function
ex5_shuffle_bytes:
    ldr q0, [x0]
    adrp x2, ex5_shuffle_pattern
    add x2, x2, :lo12:ex5_shuffle_pattern
    ldr q1, [x2]
    tbl v2.16b, {v0.16b}, v1.16b
    .global ex5_after_shuffle
ex5_after_shuffle:
    str q2, [x1]
    ret
    .size ex5_shuffle_bytes, .-ex5_shuffle_bytes

    .global ex6_insert_word_lane2
    .type ex6_insert_word_lane2, %function
ex6_insert_word_lane2:
    ldr q0, [x1]
    mov v0.s[2], w0
    .global ex6_after_insert
ex6_after_insert:
    str q0, [x2]
    ret
    .size ex6_insert_word_lane2, .-ex6_insert_word_lane2

    .global ex7_shift_left_2d_by_5
    .type ex7_shift_left_2d_by_5, %function
ex7_shift_left_2d_by_5:
    ldr q0, [x0]
    shl v0.2d, v0.2d, #5
    .global ex7_after_shift
ex7_after_shift:
    str q0, [x1]
    ret
    .size ex7_shift_left_2d_by_5, .-ex7_shift_left_2d_by_5

    .global ex8_add_u8x16
    .type ex8_add_u8x16, %function
ex8_add_u8x16:
    ldr q0, [x0]
    ldr q1, [x1]
    add v2.16b, v0.16b, v1.16b
    .global ex8_after_add
ex8_after_add:
    str q2, [x2]
    ret
    .size ex8_add_u8x16, .-ex8_add_u8x16

    .global ex9_dot_u16x8
    .type ex9_dot_u16x8, %function
ex9_dot_u16x8:
    ldr q0, [x0]
    ldr q1, [x1]
    umull v2.4s, v0.4h, v1.4h
    umull2 v3.4s, v0.8h, v1.8h
    add v2.4s, v2.4s, v3.4s
    addv s4, v2.4s
    fmov w0, s4
    .global ex9_after_reduce
ex9_after_reduce:
    ret
    .size ex9_dot_u16x8, .-ex9_dot_u16x8

    .global ex10_add_f32x4
    .type ex10_add_f32x4, %function
ex10_add_f32x4:
    ldr q0, [x0]
    ldr q1, [x1]
    fadd v2.4s, v0.4s, v1.4s
    .global ex10_after_fadd
ex10_after_fadd:
    str q2, [x2]
    ret
    .size ex10_add_f32x4, .-ex10_add_f32x4

    .global ex11_macro_zero_twice
    .type ex11_macro_zero_twice, %function
ex11_macro_zero_twice:
    movi v0.16b, #0x5a
    INIT_VEC_ZERO v0
    .global ex11_after_first_zero
ex11_after_first_zero:
    str q0, [x0]

    movi v1.16b, #0xa5
    INIT_VEC_ZERO v1
    .global ex11_after_second_zero
ex11_after_second_zero:
    str q1, [x1]
    ret
    .size ex11_macro_zero_twice, .-ex11_macro_zero_twice

    .global ex12_macro_add_two_blocks
    .type ex12_macro_add_two_blocks, %function
ex12_macro_add_two_blocks:
    SIMD_ADD16_U8_BLOCK v2, v0, v1, x0, x1, x2, 0
    .global ex12_after_block0
ex12_after_block0:
    SIMD_ADD16_U8_BLOCK v5, v3, v4, x0, x1, x2, 16
    .global ex12_after_block1
ex12_after_block1:
    ret
    .size ex12_macro_add_two_blocks, .-ex12_macro_add_two_blocks

    .section .rodata
    .balign 16
ex5_shuffle_pattern:
    .byte 15, 14, 13, 12, 8, 9, 10, 11, 3, 2, 1, 0, 4, 5, 6, 7
