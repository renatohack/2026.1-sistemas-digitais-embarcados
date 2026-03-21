.data
test_string:
    .ascii "HeLLo!\0"
expected_string:
    .ascii "hello!\0"
.balign 4
count_result:
    .word 0
status_result:
    .word 0
count_null:
    .word 0
status_null:
    .word 0

.text
.global _start

_start:
    adr x0, test_string
    bl to_lower_ascii_inplace
after_string_case:
    adr x9, count_result
    str w0, [x9]
    adr x9, status_result
    str w1, [x9]

    mov x0, xzr
    bl to_lower_ascii_inplace
after_null_case:
    adr x9, count_null
    str w0, [x9]
    adr x9, status_null
    str w1, [x9]

    adr x10, test_string
    adr x11, expected_string

.compare_loop:
    ldrb w12, [x10], #1
    ldrb w13, [x11], #1
    cmp w12, w13
    b.ne .fail
    cbz w12, .check_status
    b .compare_loop

.check_status:
    adr x9, count_result
    ldr w10, [x9]
    cmp w10, #3
    b.ne .fail

    adr x9, status_result
    ldr w10, [x9]
    cbnz w10, .fail

    adr x9, count_null
    ldr w10, [x9]
    cbnz w10, .fail

    adr x9, status_null
    ldr w10, [x9]
    cmp w10, #1
    b.ne .fail

    mov w0, wzr
    b .exit

.fail:
    mov w0, #1

.exit:
    mov x8, #93
    svc #0

.section .note.GNU-stack,"",@progbits
