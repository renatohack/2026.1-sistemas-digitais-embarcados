#ifndef TP2_H
#define TP2_H

#include <stdint.h>

uint8_t ex1_lookup_byte_byte(uint8_t index);
uint16_t ex2_lookup_byte_halfword(uint8_t index);
uint8_t ex3_lookup_word_byte(uint32_t value);
uint32_t ex4_lookup_word_word(uint8_t index);
uint64_t ex5_clear_bits_bic(uint64_t base, uint64_t mask);
uint64_t ex6_set_bits_orr(uint64_t base, uint64_t mask);
uint64_t ex7_toggle_bits_eor(uint64_t value, uint64_t mask);
uint32_t ex8_test_bits_status(uint64_t value, uint64_t mask);
uint64_t ex9_extract_field(uint64_t value, uint64_t offset, uint64_t width);
uint64_t ex10_insert_field(uint64_t base, uint64_t field, uint64_t offset, uint64_t width);
uint64_t ex11_rotate_left_manual(uint64_t value, uint64_t shift);
uint64_t ex12_pipeline(uint64_t input);

#endif
