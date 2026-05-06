#include "tp1.h"

#include <inttypes.h>
#include <stdio.h>
#include <string.h>

struct u64_to_str_case {
    const char *name;
    uint64_t value;
    size_t buffer_size;
    const char *expected_text;
    size_t expected_len;
};

static const struct u64_to_str_case k_cases[] = {
    {"zero", 0ULL, 32U, "0", 1U},
    {"one-digit", 7ULL, 32U, "7", 1U},
    {"many-digits", 1234567890123456789ULL, 32U, "1234567890123456789", 19U},
    {"uint64-max", UINT64_MAX, 32U, "18446744073709551615", 20U},
    {"small-buffer", 12345ULL, 3U, "", 0U}
};

static int run_case(const struct u64_to_str_case *test_case) {
    char buffer[64];
    const size_t produced = u64_to_str(test_case->value, buffer, test_case->buffer_size);
    const int pass = produced == test_case->expected_len &&
                     strcmp(buffer, test_case->expected_text) == 0;

    printf("case=%s\n", test_case->name);
    printf("  value=%" PRIu64 "\n", test_case->value);
    printf("  text=\"%s\"\n", buffer);
    printf("  len=%zu expected_len=%zu => %s\n",
           produced,
           test_case->expected_len,
           pass ? "PASS" : "FAIL");
    return pass ? 0 : 1;
}

int main(int argc, char **argv) {
    int failures = 0;
    int matched = 0;

    puts("Ex8 - Conversao unsigned 64-bit para string decimal");
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
