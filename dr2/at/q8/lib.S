.text
.global trapz_energy_f64
.type trapz_energy_f64, %function

trapz_energy_f64:
    cbz x0, .null_ptr                         // retorna erro se o ponteiro do vetor for nulo
    cmp x1, #2                                // verifica se ha ao menos duas amostras
    b.lt .bad_n                               // retorna erro se N < 2

    fmov d1, xzr                              // d1 = 0.0 para validar o passo dt
    fcmp d0, d1                               // compara dt com zero
    b.le .bad_dt                              // retorna erro se dt <= 0

    mov x2, x0                                // x2 = ponteiro de trabalho para percorrer o vetor
    sub x3, x1, #1                            // x3 = numero de trapezios a acumular
    ldr d2, [x2]                              // d2 = f[i] inicial
    fmov d3, xzr                              // d3 = acumulador da integral inicializado com zero
    fmov d1, #0.5                             // d1 = constante 0.5 da regra do trapezio

.loop:
    ldr d4, [x2, #8]                          // d4 = f[i+1] usando o proximo elemento do vetor
    fadd d5, d2, d4                           // soma f[i] + f[i+1]
    fmul d5, d5, d0                           // multiplica pela largura dt
    fmul d5, d5, d1                           // aplica o fator 0.5 do trapezio
    fadd d3, d3, d5                           // acumula a area parcial no total
    fmov d2, d4                               // atualiza f[i] para a proxima iteracao
    add x2, x2, #8                            // avanca o ponteiro para o proximo elemento
    subs x3, x3, #1                           // decrementa a quantidade de trapezios restantes
    b.ne .loop                                // continua enquanto ainda houver pares para integrar

    fmov d0, d3                               // retorna a integral aproximada em d0
    mov w0, wzr                               // retorna status 0 para sucesso
    ret                                       // volta ao chamador

.null_ptr:
    fmov d0, xzr                              // retorna 0.0 em caso de ponteiro nulo
    mov w0, #1                                // retorna status 1 para ponteiro nulo
    ret                                       // volta ao chamador

.bad_n:
    fmov d0, xzr                              // retorna 0.0 em caso de N invalido
    mov w0, #2                                // retorna status 2 para N<2
    ret                                       // volta ao chamador

.bad_dt:
    fmov d0, xzr                              // retorna 0.0 em caso de dt invalido
    mov w0, #3                                // retorna status 3 para dt<=0
    ret                                       // volta ao chamador

.section .note.GNU-stack,"",@progbits
