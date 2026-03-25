.text
.global normalize_saturate_i16_to_i32
.type normalize_saturate_i16_to_i32, %function

normalize_saturate_i16_to_i32:
    cbz x0, .null_ptr                         // retorna erro se o ponteiro de entrada for nulo
    cbz x1, .null_ptr                         // retorna erro se o ponteiro de saida for nulo
    cbz x2, .zero_len                         // retorna erro se N for zero

    mov x4, #-8388608                         // x4 = limite minimo de saturacao
    mov x5, #8388607                          // x5 = limite maximo de saturacao

.loop:
    ldrsh w6, [x0], #2                        // le uma amostra int16 com extensao de sinal e avanca a entrada
    smull x7, w6, w3                          // multiplica a amostra pelo ganho em 64 bits
    cmp x7, x4                                // compara o resultado com o limite minimo
    b.lt .sat_min                             // satura para o minimo se estiver abaixo do intervalo
    cmp x7, x5                                // compara o resultado com o limite maximo
    b.gt .sat_max                             // satura para o maximo se estiver acima do intervalo
    str w7, [x1], #4                          // grava o valor normalizado sem saturacao e avanca a saida
    b .next                                   // segue para a proxima iteracao

.sat_min:
    str w4, [x1], #4                          // grava o limite minimo saturado na saida
    b .next                                   // segue para a proxima iteracao

.sat_max:
    str w5, [x1], #4                          // grava o limite maximo saturado na saida

.next:
    subs x2, x2, #1                           // decrementa o numero de amostras restantes
    b.ne .loop                                // repete enquanto ainda houver amostras

    mov w0, wzr                               // retorna status 0 para indicar sucesso
    ret                                       // volta ao chamador

.zero_len:
    mov w0, #1                                // retorna status 1 para N igual a zero
    ret                                       // volta ao chamador

.null_ptr:
    mov w0, #2                                // retorna status 2 para ponteiro nulo
    ret                                       // volta ao chamador

.section .note.GNU-stack,"",@progbits
