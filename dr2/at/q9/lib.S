.text
.global affine2d_q16
.type affine2d_q16, %function

affine2d_q16:
    cbz x1, .null_ptr                         // retorna erro se o ponteiro da matriz A for nulo
    cbz x2, .null_ptr                         // retorna erro se o ponteiro do vetor b for nulo
    cbz x3, .null_ptr                         // retorna erro se o ponteiro do ponto p for nulo
    cbz x4, .null_ptr                         // retorna erro se o ponteiro da saida for nulo

    cmp w0, #0                                // verifica se o modo solicitado e A*p
    b.eq .mode_ap                             // desvia para o modo 0
    cmp w0, #1                                // verifica se o modo solicitado e A*p+b
    b.eq .mode_apb                            // desvia para o modo 1

    mov w0, #2                                // retorna status 2 para modo invalido
    ret                                       // volta ao chamador

.mode_ap:
    ldr w5, [x1]                              // carrega a00
    ldr w6, [x1, #4]                          // carrega a01
    ldr w7, [x1, #8]                          // carrega a10
    ldr w8, [x1, #12]                         // carrega a11
    ldr w9, [x3]                              // carrega p.x
    ldr w10, [x3, #4]                         // carrega p.y

    smull x11, w5, w9                         // calcula a00 * p.x em 64 bits
    smull x12, w6, w10                        // calcula a01 * p.y em 64 bits
    add x11, x11, x12                         // soma os termos da primeira linha
    asr x11, x11, #16                         // normaliza o resultado de volta para Q16.16

    smull x13, w7, w9                         // calcula a10 * p.x em 64 bits
    smull x14, w8, w10                        // calcula a11 * p.y em 64 bits
    add x13, x13, x14                         // soma os termos da segunda linha
    asr x13, x13, #16                         // normaliza o resultado de volta para Q16.16

    str w11, [x4]                             // grava out.x na memoria de saida
    str w13, [x4, #4]                         // grava out.y na memoria de saida
    mov w0, wzr                               // retorna status 0 para sucesso
    ret                                       // volta ao chamador

.mode_apb:
    ldr w5, [x1]                              // carrega a00
    ldr w6, [x1, #4]                          // carrega a01
    ldr w7, [x1, #8]                          // carrega a10
    ldr w8, [x1, #12]                         // carrega a11
    ldr w9, [x3]                              // carrega p.x
    ldr w10, [x3, #4]                         // carrega p.y
    ldr w15, [x2]                             // carrega b.x
    ldr w16, [x2, #4]                         // carrega b.y

    smull x11, w5, w9                         // calcula a00 * p.x em 64 bits
    smull x12, w6, w10                        // calcula a01 * p.y em 64 bits
    add x11, x11, x12                         // soma os termos da primeira linha
    asr x11, x11, #16                         // normaliza o resultado de volta para Q16.16
    sxtw x15, w15                             // expande b.x para 64 bits com sinal
    add x11, x11, x15                         // soma a translacao b.x ao resultado x

    smull x13, w7, w9                         // calcula a10 * p.x em 64 bits
    smull x14, w8, w10                        // calcula a11 * p.y em 64 bits
    add x13, x13, x14                         // soma os termos da segunda linha
    asr x13, x13, #16                         // normaliza o resultado de volta para Q16.16
    sxtw x16, w16                             // expande b.y para 64 bits com sinal
    add x13, x13, x16                         // soma a translacao b.y ao resultado y

    str w11, [x4]                             // grava out.x na memoria de saida
    str w13, [x4, #4]                         // grava out.y na memoria de saida
    mov w0, wzr                               // retorna status 0 para sucesso
    ret                                       // volta ao chamador

.null_ptr:
    mov w0, #1                                // retorna status 1 para ponteiro nulo
    ret                                       // volta ao chamador

.section .note.GNU-stack,"",@progbits
