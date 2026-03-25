.text
.global sin_taylor
.type sin_taylor, %function

sin_taylor:
    fmov d2, xzr                              // d2 = 0.0 para comparacoes iniciais
    fcmp d1, d2                               // verifica se eps e maior que zero
    b.le .bad_eps                             // sai com erro se eps <= 0

    cbz w0, .bad_iter                         // sai com erro se max_iter for zero

    fmov d2, d0                               // d2 = soma acumulada inicial = primeiro termo
    fmov d3, d0                               // d3 = termo corrente inicial = x
    fmul d4, d0, d0                           // d4 = x^2 para reutilizar na recorrencia
    mov w2, wzr                               // w2 = contador de termos adicionais calculados

    fabs d5, d3                               // d5 = |termo atual|
    fcmp d5, d1                               // compara |termo| com eps
    b.lt .done                                // encerra cedo se o primeiro termo ja for suficiente

.loop:
    add w2, w2, #1                            // avanca para o proximo indice k da serie
    cmp w2, w0                                // verifica se atingiu o limite de iteracoes
    b.ge .done                                // encerra se nao puder calcular mais termos

    lsl w5, w2, #1                            // w5 = 2k
    add w6, w5, #1                            // w6 = 2k + 1
    scvtf d5, w5                              // d5 = 2k em ponto flutuante
    scvtf d6, w6                              // d6 = 2k + 1 em ponto flutuante

    fmul d3, d3, d4                           // multiplica o termo atual por x^2
    fneg d3, d3                               // alterna o sinal do termo
    fdiv d3, d3, d5                           // divide por 2k
    fdiv d3, d3, d6                           // divide por 2k+1, completando a recorrencia
    fadd d2, d2, d3                           // soma o novo termo ao acumulador

    fabs d7, d3                               // d7 = |novo termo|
    fcmp d7, d1                               // compara |termo| com eps
    b.ge .loop                                // continua enquanto o termo ainda for significativo

.done:
    fmov d0, d2                               // retorna a soma acumulada em d0
    mov w1, wzr                               // retorna status 0 em w1
    ret                                       // volta ao chamador

.bad_eps:
    fmov d0, xzr                              // retorna 0.0 em caso de epsilon invalido
    mov w1, #1                                // retorna status 1 para eps invalido
    ret                                       // volta ao chamador

.bad_iter:
    fmov d0, xzr                              // retorna 0.0 em caso de max_iter invalido
    mov w1, #2                                // retorna status 2 para max_iter igual a zero
    ret                                       // volta ao chamador

.section .note.GNU-stack,"",@progbits
