#include "tp1.h"

#include <inttypes.h>
#include <stdio.h>

int main(void) {
    static const char *names[] = {
        "PERIPH_BASE",
        "GPIO_BASE",
        "UART0_BASE",
        "SYS_TIMER_BASE",
        "GPIO_GPFSEL1"
    };
    static const uint64_t expected[] = {
        TP1_PERIPH_BASE,
        TP1_GPIO_BASE,
        TP1_UART0_BASE,
        TP1_SYS_TIMER_BASE,
        TP1_GPIO_GPFSEL1
    };
    uint64_t actual[5] = {0};
    int ok = 1;

    soc_fill_addrs(actual);

    puts("Ex2 - Enderecos base e offsets do SoC");
    for (size_t i = 0; i < 5; ++i) {
        const int pass = actual[i] == expected[i];
        printf("%-13s = 0x%016" PRIx64 " | esperado = 0x%016" PRIx64 " | %s\n",
               names[i],
               actual[i],
               expected[i],
               pass ? "PASS" : "FAIL");
        if (!pass) {
            ok = 0;
        }
    }

    printf("STATUS FINAL: %s\n", ok ? "PASS" : "FAIL");
    return ok ? 0 : 1;
}
