#include "tp1.h"

#include <inttypes.h>
#include <stdio.h>
#include <string.h>

struct mp_sub_case {
    const char *name;
    uint64_t y[2];
    uint64_t z[2];
    uint64_t expected[2];
    uint64_t expected_borrow;
};

static const struct mp_sub_case k_cases[] = {
    {
        "no-borrow",
        {10ULL, 1ULL},
        {3ULL, 0ULL},
        {7ULL, 1ULL},
        0
    },
    {
        "borrow",
        {0ULL, 0ULL},
        {1ULL, 0ULL},
        {UINT64_MAX, UINT64_MAX},
        1
    }
};

static int run_case(const struct mp_sub_case *test_case) {
    uint64_t out[2] = {0};
    const uint64_t borrow = mp_sub_128(test_case->y, test_case->z, out);
    const int pass = memcmp(out, test_case->expected, sizeof(out)) == 0 &&
                     borrow == test_case->expected_borrow;

    printf("case=%s\n", test_case->name);
    fputs("  y      = ", stdout);
    tp1_print_words_le_hex(test_case->y, 2);
    putchar('\n');
    fputs("  z      = ", stdout);
    tp1_print_words_le_hex(test_case->z, 2);
    putchar('\n');
    fputs("  result = ", stdout);
    tp1_print_words_le_hex(out, 2);
    putchar('\n');
    fputs("  expect = ", stdout);
    tp1_print_words_le_hex(test_case->expected, 2);
    putchar('\n');
    printf("  borrow=%" PRIu64 " expected=%" PRIu64 " => %s\n",
           borrow,
           test_case->expected_borrow,
           pass ? "PASS" : "FAIL");
    return pass ? 0 : 1;
}

int main(int argc, char **argv) {
    int failures = 0;
    int matched = 0;

    puts("Ex7 - Subtracao unsigned de 128 bits");
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
