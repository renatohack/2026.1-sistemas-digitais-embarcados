.text
.global to_lower_ascii_inplace
.type to_lower_ascii_inplace, %function

to_lower_ascii_inplace:
    cbz x0, .null_ptr

    mov w2, wzr

.loop:
    ldrb w3, [x0]
    cbz w3, .done

    cmp w3, #'A'
    b.lt .next
    cmp w3, #'Z'
    b.gt .next

    add w3, w3, #32
    strb w3, [x0]
    add w2, w2, #1

.next:
    add x0, x0, #1
    b .loop

.done:
    mov w0, w2
    mov w1, wzr
    ret

.null_ptr:
    mov w0, wzr
    mov w1, #1
    ret

.section .note.GNU-stack,"",@progbits
