.text
.align 2

.equ TP1_OK, 0
.equ TP1_ERR_EMPTY, 1
.equ TP1_ERR_INVALID, 2
.equ TP1_ERR_OVERFLOW, 3

.global parse_i64
.type parse_i64, %function
parse_i64:
    cbz x0, .empty
    cbz x1, .invalid

    mov x2, x0
    mov w3, #0
    mov x4, #0
    mov w10, #0

    ldrb w5, [x2]
    cbz w5, .empty
    cmp w5, #'-'
    b.ne .check_plus
    mov w3, #1
    add x2, x2, #1
    b .post_sign

.check_plus:
    cmp w5, #'+'
    b.ne .post_sign
    add x2, x2, #1

.post_sign:
    ldrb w5, [x2]
    cbz w5, .empty

    ldr x8, =922337203685477580
    mov w9, #7
    cbz w3, .parse_loop
    mov w9, #8

.parse_loop:
    ldrb w5, [x2], #1
    cbz w5, .done
    sub w6, w5, #'0'
    cmp w6, #9
    b.hi .invalid

    cmp x4, x8
    b.hi .overflow
    b.ne .accumulate
    cmp w6, w9
    b.hi .overflow

.accumulate:
    add x7, x4, x4, lsl #2
    lsl x7, x7, #1
    add x4, x7, x6
    add w10, w10, #1
    b .parse_loop

.done:
    cbz w10, .empty
    cbz w3, .store_result
    neg x4, x4

.store_result:
    str x4, [x1]
    mov w0, #TP1_OK
    ret

.empty:
    mov w0, #TP1_ERR_EMPTY
    ret

.invalid:
    mov w0, #TP1_ERR_INVALID
    ret

.overflow:
    mov w0, #TP1_ERR_OVERFLOW
    ret
.size parse_i64, . - parse_i64
