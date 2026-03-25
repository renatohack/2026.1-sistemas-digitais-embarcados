.text
.global moving_avg_i32
.type moving_avg_i32, %function

moving_avg_i32:
    cbz x0, .null_ptr                         // retorna erro se o ponteiro de entrada for nulo
    cbz x1, .null_ptr                         // retorna erro se o ponteiro de saida for nulo
    cbz x2, .zero_len                         // retorna erro se N for zero
    cbz w3, .bad_window                       // retorna erro se a janela W for zero

    uxtw x6, w3                               // x6 = tamanho da janela expandido para 64 bits
    cmp x6, x2                                // verifica se W <= N
    b.hi .bad_window                          // retorna erro se a janela for maior que o vetor

    mov x4, xzr                               // x4 = indice i inicializado com zero
    mov x5, xzr                               // x5 = acumulador deslizante da janela
    sub w7, w3, #1                            // w7 = W - 1 para o teste de borda
    uxtw x7, w7                               // x7 = W - 1 expandido para 64 bits

.loop:
    cmp x4, x2                                // verifica se i ja atingiu N
    b.ge .done                                // encerra quando todo o vetor tiver sido processado

    add x8, x0, x4, lsl #2                    // calcula o endereco de in[i]
    ldr w9, [x8]                              // le o elemento atual do vetor de entrada
    sxtw x9, w9                               // expande o elemento atual para 64 bits com sinal
    add x5, x5, x9                            // soma o novo elemento ao acumulador da janela

    cmp x4, x6                                // verifica se a janela ja passou do primeiro bloco completo
    b.lt .no_sub                              // nao subtrai nada antes de i >= W
    sub x10, x4, x6                           // calcula o indice do elemento que sai da janela
    add x11, x0, x10, lsl #2                  // calcula o endereco de in[i-W]
    ldr w12, [x11]                            // le o elemento que sai da janela
    sxtw x12, w12                             // expande o elemento removido para 64 bits com sinal
    sub x5, x5, x12                           // remove esse elemento do acumulador

.no_sub:
    add x13, x1, x4, lsl #2                   // calcula o endereco de out[i]
    cmp x4, x7                                // verifica se i ainda esta antes de W-1
    b.lt .store_zero                          // grava zero enquanto a janela ainda nao estiver completa

    sdiv x14, x5, x6                          // calcula a media inteira da janela atual
    str w14, [x13]                            // grava a media calculada na saida
    b .next                                   // segue para a proxima iteracao

.store_zero:
    str wzr, [x13]                            // grava zero para as posicoes antes da janela completa

.next:
    add x4, x4, #1                            // avanca o indice i
    b .loop                                   // repete o processamento do proximo elemento

.done:
    mov w0, wzr                               // retorna status 0 para sucesso
    ret                                       // volta ao chamador

.null_ptr:
    mov w0, #1                                // retorna status 1 para ponteiro nulo
    ret                                       // volta ao chamador

.zero_len:
    mov w0, #2                                // retorna status 2 para N=0
    ret                                       // volta ao chamador

.bad_window:
    mov w0, #3                                // retorna status 3 para janela invalida
    ret                                       // volta ao chamador

.section .note.GNU-stack,"",@progbits
