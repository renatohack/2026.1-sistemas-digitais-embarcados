#include "tp1.h"

#include <inttypes.h>
#include <stdio.h>
#include <string.h>

struct parse_case {
    const char *name;
    const char *text;
    int expected_status;
    int64_t expected_value;
};

static const struct parse_case k_cases[] = {
    {"zero", "0", TP1_OK, 0},
    {"positive", "42", TP1_OK, 42},
    {"negative", "-7", TP1_OK, -7},
    {"positive-sign", "+15", TP1_OK, 15},
    {"invalid", "12abc", TP1_ERR_INVALID, 0},
    {"empty", "", TP1_ERR_EMPTY, 0}
};

static int run_case(const struct parse_case *test_case) {
    int64_t value = 0;
    const int status = parse_i64(test_case->text, &value);
    const int pass = status == test_case->expected_status &&
                     (status != TP1_OK || value == test_case->expected_value);

    printf("case=%s\n", test_case->name);
    printf("  input=\"%s\"\n", test_case->text);
    printf("  status=%s expected=%s\n",
           tp1_status_name(status),
           tp1_status_name(test_case->expected_status));
    if (status == TP1_OK) {
        printf("  value=%" PRId64 " expected=%" PRId64 "\n",
               value,
               test_case->expected_value);
    }
    printf("  result=%s\n", pass ? "PASS" : "FAIL");
    return pass ? 0 : 1;
}

int main(int argc, char **argv) {
    int failures = 0;
    int matched = 0;

    puts("Ex9 - Parsing decimal signed 64-bit");
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
