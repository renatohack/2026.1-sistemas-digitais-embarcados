.text
.global safe_div_s64
.type safe_div_s64, %function

safe_div_s64:
    cbz x1, .div_zero                         // trata imediatamente o caso de divisor zero

    mov x2, #1                                // prepara a base para construir INT64_MIN
    lsl x2, x2, #63                           // x2 = INT64_MIN
    cmp x0, x2                                // verifica se o numerador e INT64_MIN
    b.ne .do_div                              // segue para divisao normal se nao for o caso especial
    cmp x1, #-1                               // verifica se o denominador e -1
    b.ne .do_div                              // segue para divisao normal se nao for o caso especial

    mov x0, #-1                               // monta um valor com todos os bits em 1
    lsr x0, x0, #1                            // x0 = 0x7FFF_FFFF_FFFF_FFFF apos shift logico
    mov w1, #2                                // retorna status 2 para overflow evitado
    ret                                       // volta ao chamador com saturacao positiva

.do_div:
    sdiv x0, x0, x1                           // faz a divisao assinada no caso normal
    mov w1, wzr                               // retorna status 0 para sucesso
    ret                                       // volta ao chamador

.div_zero:
    mov x0, #-1                               // monta um valor com todos os bits em 1
    lsr x0, x0, #1                            // x0 = 0x7FFF_FFFF_FFFF_FFFF apos shift logico
    mov w1, #1                                // retorna status 1 para divisor zero
    ret                                       // volta ao chamador com saturacao positiva

.section .note.GNU-stack,"",@progbits
