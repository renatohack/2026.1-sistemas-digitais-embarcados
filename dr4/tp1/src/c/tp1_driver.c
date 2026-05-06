#include "tp1.h"

#include <math.h>
#include <stdio.h>
#include <string.h>

static int check_mp_add(void) {
    const uint64_t a[3] = {UINT64_MAX, UINT64_MAX, 0ULL};
    const uint64_t b[3] = {1ULL, 0ULL, 0ULL};
    const uint64_t expected[3] = {0ULL, 0ULL, 1ULL};
    uint64_t out[3] = {0};
    const uint64_t carry = mp_add_192(a, b, out);
    const int pass = memcmp(out, expected, sizeof(out)) == 0 && carry == 0;

    fputs("[driver] mp_add_192  => ", stdout);
    tp1_print_words_le_hex(out, 3);
    printf(" carry=%llu [%s]\n", (unsigned long long)carry, pass ? "PASS" : "FAIL");
    return pass ? 0 : 1;
}

static int check_parse(void) {
    int64_t value = 0;
    const int status = parse_i64("-128", &value);
    const int pass = status == TP1_OK && value == -128;

    printf("[driver] parse_i64   => status=%s value=%lld [%s]\n",
           tp1_status_name(status),
           (long long)value,
           pass ? "PASS" : "FAIL");
    return pass ? 0 : 1;
}

static int check_to_str(void) {
    char buffer[32];
    const size_t len = u64_to_str(20260426ULL, buffer, sizeof(buffer));
    const int pass = len == strlen("20260426") && strcmp(buffer, "20260426") == 0;

    printf("[driver] u64_to_str  => text=\"%s\" len=%zu [%s]\n",
           buffer,
           len,
           pass ? "PASS" : "FAIL");
    return pass ? 0 : 1;
}

static int check_division(void) {
    double value = 0.0;
    const int status = int_div_to_double(7, 2, &value);
    const int pass = status == TP1_OK && fabs(value - 3.5) < 1e-12;

    printf("[driver] int_div     => status=%s result=%.6f [%s]\n",
           tp1_status_name(status),
           value,
           pass ? "PASS" : "FAIL");
    return pass ? 0 : 1;
}

static int check_range(void) {
    int64_t value = 0;
    const int status = parse_i64_range("2048", &value);
    const int pass = status == TP1_ERR_OUT_OF_RANGE;

    printf("[driver] parse_range => status=%s [%s]\n",
           tp1_status_name(status),
           pass ? "PASS" : "FAIL");
    return pass ? 0 : 1;
}

int main(void) {
    int failures = 0;

    puts("Ex12 - Driver final de integracao");
    failures += check_mp_add();
    failures += check_parse();
    failures += check_to_str();
    failures += check_division();
    failures += check_range();

    printf("STATUS FINAL DRIVER: %s\n", failures == 0 ? "PASS" : "FAIL");
    return failures == 0 ? 0 : 1;
}
