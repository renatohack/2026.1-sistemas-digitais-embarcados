.text
.align 2

.equ PERIPH_BASE, 0x3F000000
.equ GPIO_BASE, PERIPH_BASE + 0x200000
.equ UART0_BASE, PERIPH_BASE + 0x201000
.equ SYS_TIMER_BASE, PERIPH_BASE + 0x3000
.equ GPIO_GPFSEL1, GPIO_BASE + 0x04

.global soc_fill_addrs
.type soc_fill_addrs, %function
soc_fill_addrs:
    movz x1, #0x3f00, lsl #16
    movz x2, #0x3f20, lsl #16
    movz x3, #0x1000
    movk x3, #0x3f20, lsl #16
    movz x4, #0x3000
    movk x4, #0x3f00, lsl #16
    movz x5, #0x0004
    movk x5, #0x3f20, lsl #16

    str x1, [x0]
    str x2, [x0, #8]
    str x3, [x0, #16]
    str x4, [x0, #24]
    str x5, [x0, #32]
    ret
.size soc_fill_addrs, . - soc_fill_addrs
