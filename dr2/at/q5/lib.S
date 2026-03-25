.text
.global convert_speed_q16
.type convert_speed_q16, %function

convert_speed_q16:
    cmp w0, #0                                // verifica se o modo solicitado e km/h para m/s
    b.eq .kmh_to_ms                           // desvia para a conversao do modo 0
    cmp w0, #1                                // verifica se o modo solicitado e m/s para km/h
    b.eq .ms_to_kmh                           // desvia para a conversao do modo 1
    cmp w0, #2                                // verifica se o modo solicitado e knots para m/s
    b.eq .knots_to_ms                         // desvia para a conversao do modo 2

    mov w0, wzr                               // retorna valor zero para modo invalido
    mov w2, #1                                // retorna status 1 indicando modo invalido
    ret                                       // volta ao chamador

.kmh_to_ms:
    uxtw x3, w1                               // expande o valor Q16.16 para 64 bits sem sinal
    mov x4, #1000                             // x4 = numerador da conversao km/h -> m/s
    mul x5, x3, x4                            // multiplica o valor por 1000
    mov x6, #3600                             // x6 = denominador da conversao
    udiv x5, x5, x6                           // divide por 3600 mantendo a escala Q16.16
    mov w0, w5                                // retorna o valor convertido em w0
    mov w2, wzr                               // retorna status 0 para sucesso
    ret                                       // volta ao chamador

.ms_to_kmh:
    uxtw x3, w1                               // expande o valor Q16.16 para 64 bits sem sinal
    mov x4, #3600                             // x4 = numerador da conversao m/s -> km/h
    mul x5, x3, x4                            // multiplica o valor por 3600
    mov x6, #1000                             // x6 = denominador da conversao
    udiv x5, x5, x6                           // divide por 1000 mantendo a escala Q16.16
    mov w0, w5                                // retorna o valor convertido em w0
    mov w2, wzr                               // retorna status 0 para sucesso
    ret                                       // volta ao chamador

.knots_to_ms:
    uxtw x3, w1                               // expande o valor Q16.16 para 64 bits sem sinal
    mov x4, #1852                             // x4 = numerador da conversao knots -> m/s
    mul x5, x3, x4                            // multiplica o valor por 1852
    mov x6, #3600                             // x6 = denominador da conversao
    udiv x5, x5, x6                           // divide por 3600 mantendo a escala Q16.16
    mov w0, w5                                // retorna o valor convertido em w0
    mov w2, wzr                               // retorna status 0 para sucesso
    ret                                       // volta ao chamador

.section .note.GNU-stack,"",@progbits
