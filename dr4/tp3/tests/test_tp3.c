#include "tp3.h"

#include <inttypes.h>
#include <math.h>
#include <stdbool.h>
#include <stdio.h>
#include <string.h>

#define ARRAY_LEN(x) (sizeof(x) / sizeof((x)[0]))

static unsigned failures = 0;

static void pass_bytes(const char *label, const uint8_t *got, const uint8_t *expected, size_t len) {
    if (memcmp(got, expected, len) != 0) {
        printf("[FAIL] %s\n       got     :", label);
        for (size_t i = 0; i < len; ++i) {
            printf(" %02" PRIx8, got[i]);
        }
        printf("\n       expected:");
        for (size_t i = 0; i < len; ++i) {
            printf(" %02" PRIx8, expected[i]);
        }
        putchar('\n');
        failures++;
        return;
    }

    printf("[ OK ] %s:", label);
    for (size_t i = 0; i < len; ++i) {
        printf(" %02" PRIx8, got[i]);
    }
    putchar('\n');
}

static void pass_u32x4(const char *label, const uint32_t got[4], const uint32_t expected[4]) {
    if (memcmp(got, expected, 4 * sizeof(uint32_t)) != 0) {
        printf("[FAIL] %s\n", label);
        for (size_t i = 0; i < 4; ++i) {
            printf("       lane%zu got=0x%08" PRIx32 " expected=0x%08" PRIx32 "\n", i, got[i], expected[i]);
        }
        failures++;
        return;
    }

    printf("[ OK ] %s: [0x%08" PRIx32 ", 0x%08" PRIx32 ", 0x%08" PRIx32 ", 0x%08" PRIx32 "]\n",
           label, got[0], got[1], got[2], got[3]);
}

static void pass_u64x2(const char *label, const uint64_t got[2], const uint64_t expected[2]) {
    if (memcmp(got, expected, 2 * sizeof(uint64_t)) != 0) {
        printf("[FAIL] %s\n", label);
        for (size_t i = 0; i < 2; ++i) {
            printf("       lane%zu got=0x%016" PRIx64 " expected=0x%016" PRIx64 "\n", i, got[i], expected[i]);
        }
        failures++;
        return;
    }

    printf("[ OK ] %s: [0x%016" PRIx64 ", 0x%016" PRIx64 "]\n", label, got[0], got[1]);
}

static void pass_u32(const char *label, uint32_t got, uint32_t expected) {
    if (got != expected) {
        printf("[FAIL] %s: got=0x%08" PRIx32 " expected=0x%08" PRIx32 "\n", label, got, expected);
        failures++;
        return;
    }
    printf("[ OK ] %s: 0x%08" PRIx32 "\n", label, got);
}

static void pass_f32x4(const char *label, const float got[4], const float expected[4]) {
    bool ok = true;
    for (size_t i = 0; i < 4; ++i) {
        if (fabsf(got[i] - expected[i]) > 0.00001f) {
            ok = false;
        }
    }

    if (!ok) {
        printf("[FAIL] %s\n", label);
        for (size_t i = 0; i < 4; ++i) {
            printf("       lane%zu got=%0.5f expected=%0.5f\n", i, got[i], expected[i]);
        }
        failures++;
        return;
    }

    printf("[ OK ] %s: [%0.2f, %0.2f, %0.2f, %0.2f]\n",
           label, got[0], got[1], got[2], got[3]);
}

static void run_ex1(void) {
    uint32_t initial[TP3_VEC_U32] = {0xaaaaaaaau, 0xbbbbbbbbu, 0xccccccccu, 0xddddddddu};
    uint32_t got[TP3_VEC_U32] = {0};
    uint32_t expected[TP3_VEC_U32] = {0x12345678u, 0xbbbbbbbbu, 0xccccccccu, 0xddddddddu};

    puts("\nExercicio 1 - Wn para lane baixa de Vd");
    ex1_move_w_to_low_u32(0x12345678u, initial, got);
    pass_u32x4("lane s[0] atualizada e demais lanes preservados", got, expected);
}

static void run_ex2(void) {
    uint64_t initial[TP3_VEC_U64] = {UINT64_C(0xaaaaaaaaaaaaaaaa), UINT64_C(0xbbbbbbbbbbbbbbbb)};
    uint64_t got[TP3_VEC_U64] = {0};
    uint64_t expected[TP3_VEC_U64] = {UINT64_C(0x0123456789abcdef), UINT64_C(0xbbbbbbbbbbbbbbbb)};

    puts("\nExercicio 2 - Xn para metade baixa de Vd");
    ex2_move_x_to_low_u64(UINT64_C(0x0123456789abcdef), initial, got);
    pass_u64x2("lane d[0] atualizada e d[1] preservada", got, expected);
}

static void run_ex3(void) {
    uint8_t got[TP3_VEC_BYTES] = {0xff};
    uint8_t expected[TP3_VEC_BYTES] = {0};

    puts("\nExercicio 3 - Zerar V0");
    ex3_zero_v0(got);
    pass_bytes("todos os 16 bytes zerados", got, expected, TP3_VEC_BYTES);
}

static void run_ex4(void) {
    uint8_t got[TP3_VEC_BYTES] = {0};
    uint8_t expected[TP3_VEC_BYTES];
    memset(expected, 0xff, sizeof(expected));

    puts("\nExercicio 4 - Preencher V0 com 1s");
    ex4_fill_ones_v0(got);
    pass_bytes("todos os 16 bytes em 0xff", got, expected, TP3_VEC_BYTES);
}

static void run_ex5(void) {
    const uint8_t input[TP3_VEC_BYTES] = {
        0x00, 0x11, 0x22, 0x33, 0x44, 0x55, 0x66, 0x77,
        0x88, 0x99, 0xaa, 0xbb, 0xcc, 0xdd, 0xee, 0xff,
    };
    const uint8_t expected[TP3_VEC_BYTES] = {
        0xff, 0xee, 0xdd, 0xcc, 0x88, 0x99, 0xaa, 0xbb,
        0x33, 0x22, 0x11, 0x00, 0x44, 0x55, 0x66, 0x77,
    };
    uint8_t got[TP3_VEC_BYTES] = {0};

    puts("\nExercicio 5 - Reorganizacao arbitraria de bytes");
    ex5_shuffle_bytes(input, got);
    pass_bytes("padrao TBL aplicado byte a byte", got, expected, TP3_VEC_BYTES);
}

static void run_ex6(void) {
    uint32_t initial[TP3_VEC_U32] = {0x11111111u, 0x22222222u, 0x33333333u, 0x44444444u};
    uint32_t got[TP3_VEC_U32] = {0};
    uint32_t expected[TP3_VEC_U32] = {0x11111111u, 0x22222222u, 0xdeadbeefu, 0x44444444u};

    puts("\nExercicio 6 - Inserir word em lane especifico");
    ex6_insert_word_lane2(0xdeadbeefu, initial, got);
    pass_u32x4("lane s[2] atualizado e demais preservados", got, expected);
}

static void run_ex7(void) {
    uint64_t input[TP3_VEC_U64] = {UINT64_C(0x0000000000000003), UINT64_C(0x0800000000000001)};
    uint64_t got[TP3_VEC_U64] = {0};
    uint64_t expected[TP3_VEC_U64] = {
        UINT64_C(0x0000000000000060),
        UINT64_C(0x0000000000000020),
    };

    puts("\nExercicio 7 - Shift left por 5 bits nos dois lanes de 64 bits");
    ex7_shift_left_2d_by_5(input, got);
    pass_u64x2("SHL v.2d sem cruzar lanes", got, expected);
}

static void run_ex8(void) {
    uint8_t a[TP3_VEC_BYTES];
    uint8_t b[TP3_VEC_BYTES];
    uint8_t got[TP3_VEC_BYTES] = {0};
    uint8_t expected[TP3_VEC_BYTES];

    for (size_t i = 0; i < TP3_VEC_BYTES; ++i) {
        a[i] = (uint8_t)(i * 13u + 1u);
        b[i] = (uint8_t)(0xf0u - i * 7u);
        expected[i] = (uint8_t)(a[i] + b[i]);
    }

    puts("\nExercicio 8 - Soma SIMD de 16 bytes");
    ex8_add_u8x16(a, b, got);
    pass_bytes("16 somas u8 processadas em paralelo", got, expected, TP3_VEC_BYTES);
}

static void run_ex9(void) {
    uint16_t a[8] = {1, 2, 3, 4, 100, 200, 300, 400};
    uint16_t b[8] = {5, 6, 7, 8, 9, 10, 11, 12};
    uint32_t expected = 0;

    for (size_t i = 0; i < ARRAY_LEN(a); ++i) {
        expected += (uint32_t)a[i] * (uint32_t)b[i];
    }

    puts("\nExercicio 9 - Dot product u16x8 com reducao");
    pass_u32("produto escalar parcial reduzido em registrador geral", ex9_dot_u16x8(a, b), expected);
}

static void run_ex10(void) {
    float a[4] = {1.25f, -2.5f, 100.0f, 0.125f};
    float b[4] = {2.75f, 2.0f, -40.5f, 0.875f};
    float got[4] = {0};
    float expected[4];

    for (size_t i = 0; i < ARRAY_LEN(a); ++i) {
        expected[i] = a[i] + b[i];
    }

    puts("\nExercicio 10 - Soma SIMD float32x4");
    ex10_add_f32x4(a, b, got);
    pass_f32x4("fadd v.4s validado numericamente", got, expected);
}

static void run_ex11(void) {
    uint8_t got_a[TP3_VEC_BYTES];
    uint8_t got_b[TP3_VEC_BYTES];
    uint8_t expected[TP3_VEC_BYTES] = {0};

    memset(got_a, 0xff, sizeof(got_a));
    memset(got_b, 0xff, sizeof(got_b));

    puts("\nExercicio 11 - Macro GAS basica de inicializacao");
    ex11_macro_zero_twice(got_a, got_b);
    pass_bytes("primeira expansao da macro INIT_VEC_ZERO", got_a, expected, TP3_VEC_BYTES);
    pass_bytes("segunda expansao da macro INIT_VEC_ZERO", got_b, expected, TP3_VEC_BYTES);
}

static void run_ex12(void) {
    uint8_t a[TP3_BLOCK_BYTES];
    uint8_t b[TP3_BLOCK_BYTES];
    uint8_t got[TP3_BLOCK_BYTES] = {0};
    uint8_t expected[TP3_BLOCK_BYTES];

    for (size_t i = 0; i < TP3_BLOCK_BYTES; ++i) {
        a[i] = (uint8_t)(0x20u + i * 3u);
        b[i] = (uint8_t)(0x80u - i * 5u);
        expected[i] = (uint8_t)(a[i] + b[i]);
    }

    puts("\nExercicio 12 - Macro parametrizada para dois blocos SIMD");
    ex12_macro_add_two_blocks(a, b, got);
    pass_bytes("dois blocos de 16 bytes gerados por macro", got, expected, TP3_BLOCK_BYTES);
}

int main(void) {
    puts("Validacao automatizada do TP3 - NEON SIMD e macros GAS");
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
