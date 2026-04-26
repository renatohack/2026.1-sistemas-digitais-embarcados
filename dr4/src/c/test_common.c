#include "tp1.h"

#include <inttypes.h>
#include <stdio.h>

const char *tp1_status_name(int status) {
    switch (status) {
    case TP1_OK:
        return "OK";
    case TP1_ERR_EMPTY:
        return "EMPTY";
    case TP1_ERR_INVALID:
        return "INVALID";
    case TP1_ERR_OVERFLOW:
        return "OVERFLOW";
    case TP1_ERR_OUT_OF_RANGE:
        return "OUT_OF_RANGE";
    case TP1_ERR_DIV_BY_ZERO:
        return "DIV_BY_ZERO";
    case TP1_ERR_BUFFER_TOO_SMALL:
        return "BUFFER_TOO_SMALL";
    default:
        return "UNKNOWN";
    }
}

void tp1_print_words_le_hex(const uint64_t *words, size_t count) {
    if (words == NULL || count == 0) {
        fputs("0x0", stdout);
        return;
    }

    fputs("0x", stdout);
    for (size_t i = count; i > 0; --i) {
        printf("%016" PRIx64, words[i - 1]);
        if (i > 1) {
            putchar('_');
        }
    }
}
