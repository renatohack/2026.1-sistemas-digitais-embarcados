.text
.global poly_horner_q16_sat
.type poly_horner_q16_sat, %function

poly_horner_q16_sat:
    cbz x0, .null_ptr                         // retorna erro se o ponteiro de coeficientes for nulo
    cbz x1, .bad_n                            // retorna erro se N for zero

    mov x9, x1                                // x9 = contador de coeficientes restantes
    ldr w3, [x0], #4                          // le o primeiro coeficiente do polinomio
    sxtw x3, w3                               // expande o acumulador inicial para 64 bits com sinal
    sxtw x2, w2                               // expande x para 64 bits com sinal
    mov w8, wzr                               // w8 = status de saturacao inicializado com zero

    mov w4, #0x7fffffff                       // w4 = limite maximo de 32 bits com sinal
    sxtw x4, w4                               // expande o limite maximo para 64 bits
    mov w5, #0x80000000                       // w5 = limite minimo de 32 bits com sinal
    sxtw x5, w5                               // expande o limite minimo para 64 bits

    subs x9, x9, #1                           // desconta o coeficiente inicial ja carregado
    b.eq .done                                // encerra se o polinomio tiver apenas um coeficiente

.loop:
    ldr w6, [x0], #4                          // le o proximo coeficiente e avanca o ponteiro
    sxtw x6, w6                               // expande o coeficiente para 64 bits com sinal
    mul x7, x3, x2                            // calcula acc * x em 64 bits
    asr x7, x7, #16                           // normaliza o produto de volta para Q16.16
    add x7, x7, x6                            // soma o coeficiente atual pelo metodo de Horner

    cmp x7, x4                                // verifica se o acumulador ultrapassou o limite maximo
    b.gt .sat_max                             // satura para o maximo se houver overflow positivo
    cmp x7, x5                                // verifica se o acumulador ficou abaixo do limite minimo
    b.lt .sat_min                             // satura para o minimo se houver overflow negativo

    mov x3, x7                                // atualiza o acumulador com o valor calculado
    b .next                                   // segue para o proximo coeficiente

.sat_max:
    mov x3, x4                                // fixa o acumulador no limite maximo
    mov w8, #3                                // marca status 3 para indicar saturacao
    b .next                                   // segue para o proximo coeficiente

.sat_min:
    mov x3, x5                                // fixa o acumulador no limite minimo
    mov w8, #3                                // marca status 3 para indicar saturacao

.next:
    subs x9, x9, #1                           // decrementa a quantidade de coeficientes restantes
    b.ne .loop                                // continua enquanto ainda houver coeficientes a processar

.done:
    mov w0, w3                                // retorna o valor final do polinomio em w0
    mov w1, w8                                // retorna o status final em w1
    ret                                       // volta ao chamador

.bad_n:
    mov w0, wzr                               // retorna valor zero quando N e invalido
    mov w1, #2                                // retorna status 2 para N invalido
    ret                                       // volta ao chamador

.null_ptr:
    mov w0, wzr                               // retorna valor zero quando o ponteiro e nulo
    mov w1, #1                                // retorna status 1 para ponteiro nulo
    ret                                       // volta ao chamador

.section .note.GNU-stack,"",@progbits
