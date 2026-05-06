#include "tp1.h"

#include <math.h>
#include <stdio.h>
#include <string.h>

struct div_case {
    const char *name;
    int64_t a;
    int64_t b;
    int expected_status;
    double expected_value;
};

static const struct div_case k_cases[] = {
    {"seven-over-two", 7, 2, TP1_OK, 3.5},
    {"negative", -9, 4, TP1_OK, -2.25},
    {"div-zero", 5, 0, TP1_ERR_DIV_BY_ZERO, 0.0}
};

static int run_case(const struct div_case *test_case) {
    double out = -1.0;
    const int status = int_div_to_double(test_case->a, test_case->b, &out);
    const int pass = status == test_case->expected_status &&
                     (status != TP1_OK || fabs(out - test_case->expected_value) < 1e-12) &&
                     (status == TP1_OK || out == test_case->expected_value);

    printf("case=%s\n", test_case->name);
    printf("  a=%lld b=%lld\n",
           (long long)test_case->a,
           (long long)test_case->b);
    printf("  status=%s expected=%s\n",
           tp1_status_name(status),
           tp1_status_name(test_case->expected_status));
    printf("  result=%.12f expected=%.12f\n", out, test_case->expected_value);
    printf("  check=%s\n", pass ? "PASS" : "FAIL");
    return pass ? 0 : 1;
}

int main(int argc, char **argv) {
    int failures = 0;
    int matched = 0;

    puts("Ex10 - Conversao para double e divisao");
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
