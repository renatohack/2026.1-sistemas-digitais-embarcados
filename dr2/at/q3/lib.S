.text
.global dot_i32_checked
.type dot_i32_checked, %function

dot_i32_checked:
    cbz x0, .null_ptr                         // retorna erro se o vetor A for nulo
    cbz x1, .null_ptr                         // retorna erro se o vetor B for nulo
    cbz x2, .zero_len                         // retorna erro se N for zero

    mov x3, xzr                               // x3 = acumulador de 64 bits inicializado com zero

.loop:
    ldr w4, [x0], #4                          // le a[i] e avanca o ponteiro do vetor A
    ldr w5, [x1], #4                          // le b[i] e avanca o ponteiro do vetor B
    smull x6, w4, w5                          // calcula a[i] * b[i] em 64 bits
    adds x7, x3, x6                           // soma o produto ao acumulador atual atualizando flags
    b.vs .overflow                            // interrompe imediatamente se houver overflow assinado
    mov x3, x7                                // confirma a nova soma no acumulador
    subs x2, x2, #1                           // decrementa a quantidade de elementos restantes
    b.ne .loop                                // repete enquanto ainda houver elementos

    mov x0, x3                                // retorna o acumulador final em x0
    mov w1, wzr                               // retorna status 0 em w1
    ret                                       // volta ao chamador

.overflow:
    mov x0, x3                                // retorna a soma acumulada antes do overflow
    mov w1, #3                                // retorna status 3 para overflow detectado
    ret                                       // volta ao chamador

.zero_len:
    mov x0, xzr                               // retorna soma zero quando N e invalido
    mov w1, #1                                // retorna status 1 para N=0
    ret                                       // volta ao chamador

.null_ptr:
    mov x0, xzr                               // retorna soma zero quando ha ponteiro nulo
    mov w1, #2                                // retorna status 2 para ponteiro nulo
    ret                                       // volta ao chamador

.section .note.GNU-stack,"",@progbits
