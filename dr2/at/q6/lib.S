.text
.global to_lower_ascii_inplace
.type to_lower_ascii_inplace, %function

to_lower_ascii_inplace:
    cbz x0, .null_ptr                         // retorna erro se o ponteiro da string for nulo

    mov w2, wzr                               // w2 = contador de caracteres convertidos

.loop:
    ldrb w3, [x0]                             // le o byte atual da string
    cbz w3, .done                             // encerra ao encontrar o terminador nulo

    cmp w3, #'A'                              // verifica se o caractere e menor que 'A'
    b.lt .next                                // pula a conversao se nao for letra maiuscula
    cmp w3, #'Z'                              // verifica se o caractere e maior que 'Z'
    b.gt .next                                // pula a conversao se nao for letra maiuscula

    add w3, w3, #32                           // soma 32 para converter ASCII maiusculo em minusculo
    strb w3, [x0]                             // grava o caractere convertido de volta na string
    add w2, w2, #1                            // incrementa o contador de conversoes

.next:
    add x0, x0, #1                            // avanca para o proximo byte da string
    b .loop                                   // repete o processamento do proximo caractere

.done:
    mov w0, w2                                // retorna em w0 a quantidade de caracteres convertidos
    mov w1, wzr                               // retorna status 0 para sucesso
    ret                                       // volta ao chamador

.null_ptr:
    mov w0, wzr                               // retorna contador zero em caso de ponteiro nulo
    mov w1, #1                                // retorna status 1 para ponteiro nulo
    ret                                       // volta ao chamador

.section .note.GNU-stack,"",@progbits
