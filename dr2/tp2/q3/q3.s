.section .data
value_a:
    .quad 100
value_b:
    .quad 200

.section .text
.global _start
_start:
    ldr x0, =value_a
    ldr x1, [x0]              // Le value_a da memoria.

    ldr x0, =value_b
    ldr x2, [x0]              // Le value_b da memoria.

done:
    mov x8, #93
    mov x0, #0
    svc #0
