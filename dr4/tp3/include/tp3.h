#ifndef TP3_H
#define TP3_H

#include <stdint.h>

enum {
    TP3_VEC_BYTES = 16,
    TP3_VEC_U32 = 4,
    TP3_VEC_U64 = 2,
    TP3_BLOCK_BYTES = 32,
};

void ex1_move_w_to_low_u32(uint32_t value, const uint32_t initial[TP3_VEC_U32], uint32_t out[TP3_VEC_U32]);
void ex2_move_x_to_low_u64(uint64_t value, const uint64_t initial[TP3_VEC_U64], uint64_t out[TP3_VEC_U64]);
void ex3_zero_v0(uint8_t out[TP3_VEC_BYTES]);
void ex4_fill_ones_v0(uint8_t out[TP3_VEC_BYTES]);
void ex5_shuffle_bytes(const uint8_t input[TP3_VEC_BYTES], uint8_t out[TP3_VEC_BYTES]);
void ex6_insert_word_lane2(uint32_t value, const uint32_t initial[TP3_VEC_U32], uint32_t out[TP3_VEC_U32]);
void ex7_shift_left_2d_by_5(const uint64_t input[TP3_VEC_U64], uint64_t out[TP3_VEC_U64]);
void ex8_add_u8x16(const uint8_t a[TP3_VEC_BYTES], const uint8_t b[TP3_VEC_BYTES], uint8_t out[TP3_VEC_BYTES]);
uint32_t ex9_dot_u16x8(const uint16_t a[8], const uint16_t b[8]);
void ex10_add_f32x4(const float a[4], const float b[4], float out[4]);
void ex11_macro_zero_twice(uint8_t out_a[TP3_VEC_BYTES], uint8_t out_b[TP3_VEC_BYTES]);
void ex12_macro_add_two_blocks(const uint8_t a[TP3_BLOCK_BYTES], const uint8_t b[TP3_BLOCK_BYTES], uint8_t out[TP3_BLOCK_BYTES]);

#endif
