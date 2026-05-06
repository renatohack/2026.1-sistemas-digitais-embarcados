#include "tp1.h"

#include <inttypes.h>
#include <stdio.h>
#include <string.h>

struct range_case {
    const char *name;
    const char *text;
    int expected_status;
    int64_t expected_value;
};

static const struct range_case k_cases[] = {
    {"inside-range", "500", TP1_OK, 500},
    {"below-min", "-1001", TP1_ERR_OUT_OF_RANGE, 0},
    {"above-max", "1001", TP1_ERR_OUT_OF_RANGE, 0},
    {"invalid", "9x", TP1_ERR_INVALID, 0},
    {"empty", "", TP1_ERR_INVALID, 0},
    {"signed-valid", "-10", TP1_OK, -10}
};

static int run_case(const struct range_case *test_case) {
    int64_t value = 0;
    const int status = parse_i64_range(test_case->text, &value);
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

    printf("Ex11 - Parsing com faixa [%lld, %lld]\n",
           (long long)TP1_RANGE_MIN,
           (long long)TP1_RANGE_MAX);
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
