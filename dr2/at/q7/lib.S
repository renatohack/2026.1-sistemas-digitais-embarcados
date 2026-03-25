.text
.global sqrt_nr
.type sqrt_nr, %function

sqrt_nr:
    fmov d2, xzr                              // d2 = 0.0 para a validacao inicial
    fcmp d0, d2                               // verifica se a entrada e negativa
    b.lt .bad_input                           // sai com erro se a < 0

    cbz w0, .bad_iter                         // sai com erro se max_iter for zero

    fmov d4, d0                               // d4 = copia de 'a' para usar na recorrencia
    fmov d3, #1.0                             // d3 = constante 1.0 para o chute minimo
    fcmp d0, d3                               // verifica se a >= 1.0
    b.ge .use_a_as_guess                      // usa a propria entrada como chute se ela for >= 1

    fmov d2, d3                               // d2 = chute inicial 1.0 para evitar divisao por zero
    b .loop_setup                             // vai para a preparacao do laco

.use_a_as_guess:
    fmov d2, d0                               // d2 = chute inicial igual ao proprio valor 'a'

.loop_setup:
    mov w2, w0                                // w2 = contador de iteracoes restantes
    fmov d5, #0.5                             // d5 = constante 0.5 usada na media da iteracao

.loop:
    fdiv d6, d4, d2                           // d6 = a / x_n
    fadd d2, d2, d6                           // soma x_n + a/x_n
    fmul d2, d2, d5                           // calcula x_(n+1) = 0.5 * (x_n + a/x_n)
    subs w2, w2, #1                           // decrementa o numero de iteracoes restantes
    b.ne .loop                                // continua ate completar max_iter passos

    fmov d0, d2                               // retorna a aproximacao final em d0
    mov w1, wzr                               // retorna status 0 para sucesso
    ret                                       // volta ao chamador

.bad_input:
    fmov d0, xzr                              // retorna 0.0 em caso de entrada invalida
    mov w1, #1                                // retorna status 1 para a < 0
    ret                                       // volta ao chamador

.bad_iter:
    fmov d0, xzr                              // retorna 0.0 em caso de max_iter invalido
    mov w1, #2                                // retorna status 2 para max_iter igual a zero
    ret                                       // volta ao chamador

.section .note.GNU-stack,"",@progbits
