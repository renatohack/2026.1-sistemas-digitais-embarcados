#ifndef TP1_H
#define TP1_H

#include <stddef.h>
#include <stdint.h>

#define TP1_PERIPH_BASE 0x3F000000ULL
#define TP1_GPIO_BASE 0x3F200000ULL
#define TP1_UART0_BASE 0x3F201000ULL
#define TP1_SYS_TIMER_BASE 0x3F003000ULL
#define TP1_GPIO_GPFSEL1 0x3F200004ULL

#define TP1_RANGE_MIN (-1000LL)
#define TP1_RANGE_MAX (1000LL)

enum tp1_status_code {
    TP1_OK = 0,
    TP1_ERR_EMPTY = 1,
    TP1_ERR_INVALID = 2,
    TP1_ERR_OVERFLOW = 3,
    TP1_ERR_OUT_OF_RANGE = 4,
    TP1_ERR_DIV_BY_ZERO = 5,
    TP1_ERR_BUFFER_TOO_SMALL = 6
};

void soc_fill_addrs(uint64_t *dst);
uint64_t mp_add_192(const uint64_t *a, const uint64_t *b, uint64_t *out);
uint64_t mp_sub_128(const uint64_t *y, const uint64_t *z, uint64_t *out);
size_t u64_to_str(uint64_t value, char *buf, size_t buf_size);
int parse_i64(const char *text, int64_t *out);
int int_div_to_double(int64_t a, int64_t b, double *out);
int parse_i64_range(const char *text, int64_t *out);

const char *tp1_status_name(int status);
void tp1_print_words_le_hex(const uint64_t *words, size_t count);

#endif
