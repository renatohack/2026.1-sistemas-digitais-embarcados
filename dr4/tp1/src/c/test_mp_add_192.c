#include "tp1.h"

#include <inttypes.h>
#include <stdio.h>
#include <string.h>

struct mp_add_case {
    const char *name;
    uint64_t a[3];
    uint64_t b[3];
    uint64_t expected[3];
    uint64_t expected_carry;
};

static const struct mp_add_case k_cases[] = {
    {
        "no-carry",
        {0x10ULL, 0x20ULL, 0x30ULL},
        {0x1ULL, 0x2ULL, 0x3ULL},
        {0x11ULL, 0x22ULL, 0x33ULL},
        0
    },
    {
        "carry-low-mid",
        {UINT64_MAX, 0x1234ULL, 0x0ULL},
        {1ULL, 0x2ULL, 0x0ULL},
        {0x0ULL, 0x1237ULL, 0x0ULL},
        0
    },
    {
        "carry-through-high",
        {UINT64_MAX, UINT64_MAX, 0x0ULL},
        {1ULL, 0x0ULL, 0x0ULL},
        {0x0ULL, 0x0ULL, 0x1ULL},
        0
    },
    {
        "final-overflow",
        {UINT64_MAX, UINT64_MAX, UINT64_MAX},
        {1ULL, 0x0ULL, 0x0ULL},
        {0x0ULL, 0x0ULL, 0x0ULL},
        1
    }
};

static int run_case(const struct mp_add_case *test_case) {
    uint64_t out[3] = {0};
    const uint64_t carry = mp_add_192(test_case->a, test_case->b, out);
    const int pass = memcmp(out, test_case->expected, sizeof(out)) == 0 &&
                     carry == test_case->expected_carry;

    printf("case=%s\n", test_case->name);
    fputs("  a   = ", stdout);
    tp1_print_words_le_hex(test_case->a, 3);
    putchar('\n');
    fputs("  b   = ", stdout);
    tp1_print_words_le_hex(test_case->b, 3);
    putchar('\n');
    fputs("  out = ", stdout);
    tp1_print_words_le_hex(out, 3);
    putchar('\n');
    fputs("  exp = ", stdout);
    tp1_print_words_le_hex(test_case->expected, 3);
    putchar('\n');
    printf("  carry=%" PRIu64 " expected=%" PRIu64 " => %s\n",
           carry,
           test_case->expected_carry,
           pass ? "PASS" : "FAIL");
    return pass ? 0 : 1;
}

int main(int argc, char **argv) {
    int failures = 0;
    int matched = 0;

    puts("Ex6 - Soma unsigned de 192 bits");
    for (size_t i = 0; i < sizeof(k_cases) / sizeof(k_cases[0]); ++i) {
        if (argc > 1 && strcmp(argv[1], k_cases[i].name) != 0) {
            continue;
        }
        matched = 1;
        failures += run_case(&k_cases[i]);
    }

    if (!matched) {
        fprintf(stderr, "Caso nao encontrado.\n");
        return 2;
    }

    printf("STATUS FINAL: %s\n", failures == 0 ? "PASS" : "FAIL");
    return failures == 0 ? 0 : 1;
}
