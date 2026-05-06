#include "tp2.h"

#include <inttypes.h>
#include <stdbool.h>
#include <stdio.h>

#define ARRAY_LEN(x) (sizeof(x) / sizeof((x)[0]))

static unsigned failures = 0;

static uint8_t expected_ex1(uint8_t index) {
    return (uint8_t)((index * 73u + 41u) & 0xffu);
}

static uint16_t expected_ex2(uint8_t index) {
    return (uint16_t)((0x1200u + index * 257u) & 0xffffu);
}

static uint8_t expected_ex3(uint32_t value) {
    return (uint8_t)(((uint8_t)value) ^ 0xa5u);
}

static uint32_t expected_ex4(uint8_t index) {
    return (uint32_t)(0xa5000000u + index * 0x01010101u);
}

static uint64_t mask_for_width(uint64_t width) {
    if (width == 0) {
        return 0;
    }
    if (width >= 64) {
        return UINT64_MAX;
    }
    return (UINT64_C(1) << width) - 1u;
}

static uint64_t expected_ex9(uint64_t value, uint64_t offset, uint64_t width) {
    if (width == 0) {
        return 0;
    }
    return (value >> offset) & mask_for_width(width);
}

static uint64_t expected_ex10(uint64_t base, uint64_t field, uint64_t offset, uint64_t width) {
    if (width == 0) {
        return base;
    }
    if (width >= 64) {
        return field;
    }

    uint64_t mask = mask_for_width(width) << offset;
    uint64_t positioned = (field & mask_for_width(width)) << offset;
    return (base & ~mask) | positioned;
}

static uint64_t expected_ex11(uint64_t value, uint64_t shift) {
    shift &= 63u;
    if (shift == 0) {
        return value;
    }
    return (value << shift) | (value >> (64u - shift));
}

static uint64_t expected_ex12(uint64_t input) {
    uint64_t index = (input >> 12) & 0xfu;
    uint64_t lookup = (uint8_t)((0x12u + index * 11u) & 0xffu);
    uint64_t payload = (lookup & 0x3fu) << 20;
    uint64_t cleared = input & ~(UINT64_C(0x3f) << 20);
    return cleared | payload | (UINT64_C(1) << 40);
}

static void pass_u64(const char *label, uint64_t got, uint64_t expected) {
    if (got != expected) {
        printf("[FAIL] %s: got=0x%016" PRIx64 " expected=0x%016" PRIx64 "\n", label, got, expected);
        failures++;
        return;
    }
    printf("[ OK ] %s: 0x%016" PRIx64 "\n", label, got);
}

static void pass_u32(const char *label, uint32_t got, uint32_t expected) {
    if (got != expected) {
        printf("[FAIL] %s: got=0x%08" PRIx32 " expected=0x%08" PRIx32 "\n", label, got, expected);
        failures++;
        return;
    }
    printf("[ OK ] %s: 0x%08" PRIx32 "\n", label, got);
}

static void pass_u16(const char *label, uint16_t got, uint16_t expected) {
    if (got != expected) {
        printf("[FAIL] %s: got=0x%04" PRIx16 " expected=0x%04" PRIx16 "\n", label, got, expected);
        failures++;
        return;
    }
    printf("[ OK ] %s: 0x%04" PRIx16 "\n", label, got);
}

static void pass_u8(const char *label, uint8_t got, uint8_t expected) {
    if (got != expected) {
        printf("[FAIL] %s: got=0x%02" PRIx8 " expected=0x%02" PRIx8 "\n", label, got, expected);
        failures++;
        return;
    }
    printf("[ OK ] %s: 0x%02" PRIx8 "\n", label, got);
}

static void run_ex1(void) {
    const uint8_t cases[] = {0x00u, 0x01u, 0x2au, 0x80u, 0xffu};
    puts("\nExercicio 1 - Lookup table byte -> byte");
    for (size_t i = 0; i < ARRAY_LEN(cases); ++i) {
        uint8_t index = cases[i];
        char label[64];
        snprintf(label, sizeof(label), "ex1[%u]", index);
        pass_u8(label, ex1_lookup_byte_byte(index), expected_ex1(index));
    }
}

static void run_ex2(void) {
    const uint8_t cases[] = {0x00u, 0x03u, 0x40u, 0x7fu, 0xffu};
    puts("\nExercicio 2 - Lookup table byte -> halfword");
    for (size_t i = 0; i < ARRAY_LEN(cases); ++i) {
        uint8_t index = cases[i];
        char label[64];
        snprintf(label, sizeof(label), "ex2[%u]", index);
        pass_u16(label, ex2_lookup_byte_halfword(index), expected_ex2(index));
    }
}

static void run_ex3(void) {
    const uint32_t cases[] = {
        UINT32_C(0x00000000),
        UINT32_C(0x000000ff),
        UINT32_C(0x12345678),
        UINT32_C(0x89abcde0),
        UINT32_C(0xffffffff),
    };
    puts("\nExercicio 3 - Lookup table word -> byte");
    for (size_t i = 0; i < ARRAY_LEN(cases); ++i) {
        uint32_t value = cases[i];
        char label[64];
        snprintf(label, sizeof(label), "ex3[0x%08" PRIx32 "]", value);
        pass_u8(label, ex3_lookup_word_byte(value), expected_ex3(value));
    }
}

static void run_ex4(void) {
    const uint8_t cases[] = {0x00u, 0x01u, 0x04u, 0x55u, 0xffu};
    puts("\nExercicio 4 - Lookup table word -> word");
    for (size_t i = 0; i < ARRAY_LEN(cases); ++i) {
        uint8_t index = cases[i];
        char label[64];
        snprintf(label, sizeof(label), "ex4[%u]", index);
        pass_u32(label, ex4_lookup_word_word(index), expected_ex4(index));
    }
}

static void run_ex5(void) {
    struct {
        uint64_t base;
        uint64_t mask;
    } cases[] = {
        {UINT64_C(0xffffffffffffffff), UINT64_C(0x00ff00ff00ff00ff)},
        {UINT64_C(0x123456789abcdef0), UINT64_C(0x0000ffff0000ffff)},
        {UINT64_C(0xaaaaaaaa55555555), UINT64_C(0x0f0f0f0f0f0f0f0f)},
    };
    puts("\nExercicio 5 - Limpeza de bits com BIC");
    for (size_t i = 0; i < ARRAY_LEN(cases); ++i) {
        uint64_t expected = cases[i].base & ~cases[i].mask;
        char label[64];
        snprintf(label, sizeof(label), "ex5_case%zu", i + 1);
        pass_u64(label, ex5_clear_bits_bic(cases[i].base, cases[i].mask), expected);
    }
}

static void run_ex6(void) {
    struct {
        uint64_t base;
        uint64_t mask;
    } cases[] = {
        {UINT64_C(0x0000000000000000), UINT64_C(0x00ff00ff00ff00ff)},
        {UINT64_C(0x123456789abcdef0), UINT64_C(0x0000ffff0000ffff)},
        {UINT64_C(0xaaaaaaaa55555555), UINT64_C(0x0f0f0f0f0f0f0f0f)},
    };
    puts("\nExercicio 6 - Ativacao de bits com ORR");
    for (size_t i = 0; i < ARRAY_LEN(cases); ++i) {
        uint64_t expected = cases[i].base | cases[i].mask;
        char label[64];
        snprintf(label, sizeof(label), "ex6_case%zu", i + 1);
        pass_u64(label, ex6_set_bits_orr(cases[i].base, cases[i].mask), expected);
    }
}

static void run_ex7(void) {
    struct {
        uint64_t value;
        uint64_t mask;
    } cases[] = {
        {UINT64_C(0xffff0000ffff0000), UINT64_C(0x00ff00ff00ff00ff)},
        {UINT64_C(0x123456789abcdef0), UINT64_C(0x0000ffff0000ffff)},
        {UINT64_C(0xaaaaaaaa55555555), UINT64_C(0x0f0f0f0f0f0f0f0f)},
    };
    puts("\nExercicio 7 - Alternancia de bits com EOR");
    for (size_t i = 0; i < ARRAY_LEN(cases); ++i) {
        uint64_t expected = cases[i].value ^ cases[i].mask;
        char label[64];
        snprintf(label, sizeof(label), "ex7_case%zu", i + 1);
        pass_u64(label, ex7_toggle_bits_eor(cases[i].value, cases[i].mask), expected);
    }
}

static void run_ex8(void) {
    struct {
        uint64_t value;
        uint64_t mask;
        uint32_t expected;
    } cases[] = {
        {UINT64_C(0x0000000000000000), UINT64_C(0x00000000000000ff), 0u},
        {UINT64_C(0x0000000000000040), UINT64_C(0x00000000000000ff), 1u},
        {UINT64_C(0x8000000000000000), UINT64_C(0x4000000000000000), 0u},
        {UINT64_C(0x8000000000000000), UINT64_C(0x8000000000000000), 1u},
    };
    puts("\nExercicio 8 - Teste de bits por mascaramento");
    for (size_t i = 0; i < ARRAY_LEN(cases); ++i) {
        char label[64];
        snprintf(label, sizeof(label), "ex8_case%zu", i + 1);
        pass_u32(label, ex8_test_bits_status(cases[i].value, cases[i].mask), cases[i].expected);
    }
}

static void run_ex9(void) {
    struct {
        uint64_t value;
        uint64_t offset;
        uint64_t width;
    } cases[] = {
        {UINT64_C(0xfedcba9876543210), 4u, 8u},
        {UINT64_C(0x0123456789abcdef), 12u, 12u},
        {UINT64_C(0xffff0000aaaa5555), 32u, 16u},
        {UINT64_C(0xdeadbeefcafebabe), 0u, 0u},
    };
    puts("\nExercicio 9 - Extracao de campo");
    for (size_t i = 0; i < ARRAY_LEN(cases); ++i) {
        uint64_t expected = expected_ex9(cases[i].value, cases[i].offset, cases[i].width);
        char label[80];
        snprintf(label, sizeof(label), "ex9_case%zu", i + 1);
        pass_u64(label, ex9_extract_field(cases[i].value, cases[i].offset, cases[i].width), expected);
    }
}

static void run_ex10(void) {
    struct {
        uint64_t base;
        uint64_t field;
        uint64_t offset;
        uint64_t width;
    } cases[] = {
        {UINT64_C(0xffff0000ffff0000), UINT64_C(0x12), 8u, 8u},
        {UINT64_C(0x0123456789abcdef), UINT64_C(0x155), 20u, 9u},
        {UINT64_C(0x0000000000000000), UINT64_C(0xdead), 32u, 16u},
        {UINT64_C(0x123456789abcdef0), UINT64_C(0xbeef), 0u, 0u},
    };
    puts("\nExercicio 10 - Insercao de campo");
    for (size_t i = 0; i < ARRAY_LEN(cases); ++i) {
        uint64_t expected = expected_ex10(cases[i].base, cases[i].field, cases[i].offset, cases[i].width);
        char label[80];
        snprintf(label, sizeof(label), "ex10_case%zu", i + 1);
        pass_u64(
            label,
            ex10_insert_field(cases[i].base, cases[i].field, cases[i].offset, cases[i].width),
            expected
        );
    }
}

static void run_ex11(void) {
    struct {
        uint64_t value;
        uint64_t shift;
    } cases[] = {
        {UINT64_C(0x0123456789abcdef), 0u},
        {UINT64_C(0x0123456789abcdef), 8u},
        {UINT64_C(0x8000000000000001), 1u},
        {UINT64_C(0xf0f0f0f00f0f0f0f), 17u},
        {UINT64_C(0x123456789abcdef0), 68u},
    };
    puts("\nExercicio 11 - Rotacao manual a esquerda");
    for (size_t i = 0; i < ARRAY_LEN(cases); ++i) {
        uint64_t expected = expected_ex11(cases[i].value, cases[i].shift);
        char label[80];
        snprintf(label, sizeof(label), "ex11_case%zu", i + 1);
        pass_u64(label, ex11_rotate_left_manual(cases[i].value, cases[i].shift), expected);
    }
}

static void run_ex12(void) {
    const uint64_t cases[] = {
        UINT64_C(0x123456789abcdef0),
        UINT64_C(0x000000000000f123),
        UINT64_C(0xffffffffffffffff),
        UINT64_C(0x13579bdf2468ace0),
    };
    puts("\nExercicio 12 - Pipeline completo");
    for (size_t i = 0; i < ARRAY_LEN(cases); ++i) {
        uint64_t input = cases[i];
        char label[80];
        snprintf(label, sizeof(label), "ex12_case%zu", i + 1);
        pass_u64(label, ex12_pipeline(input), expected_ex12(input));
    }
}

int main(void) {
    puts("Validacao automatizada do TP2 - Assembly ARM64");
    puts("Execucao cruzada: binario AArch64 rodando em qemu-aarch64");

    run_ex1();
    run_ex2();
    run_ex3();
    run_ex4();
    run_ex5();
    run_ex6();
    run_ex7();
    run_ex8();
    run_ex9();
    run_ex10();
    run_ex11();
    run_ex12();

    if (failures != 0) {
        printf("\nResultado final: %u falha(s).\n", failures);
        return 1;
    }

    puts("\nResultado final: todos os 12 exercicios passaram nos testes.");
    return 0;
}
