.data
.balign 8
a_four:
    .double 4.0
a_neg:
    .double -1.0
expected_two:
    .double 2.0
tol:
    .double 0.000001
result_four:
    .double 0.0
result_neg:
    .double 0.0
result_zero_iter:
    .double 0.0
.balign 4
status_four:
    .word 0
status_neg:
    .word 0
status_zero_iter:
    .word 0

.text
.global _start

_start:
    adr x9, a_four                            // x9 = endereco do valor 4.0
    ldr d0, [x9]                              // d0 = valor de entrada para a raiz quadrada
    mov w0, #8                                // w0 = numero de iteracoes do metodo
    bl sqrt_nr                                // calcula sqrt(4.0) por Newton-Raphson
after_positive_case:
    adr x10, result_four                      // x10 = endereco para salvar o resultado do caso positivo
    str d0, [x10]                             // grava a aproximacao retornada
    adr x10, status_four                      // x10 = endereco para salvar o status do caso positivo
    str w1, [x10]                             // grava o status retornado

    adr x9, a_neg                             // x9 = endereco do valor negativo de teste
    ldr d0, [x9]                              // d0 = valor de entrada invalido
    mov w0, #8                                // w0 = iteracoes arbitrarias para o teste
    bl sqrt_nr                                // chama a funcao esperando erro por entrada negativa
after_negative_case:
    adr x10, result_neg                       // x10 = endereco para salvar o resultado do caso negativo
    str d0, [x10]                             // grava o valor retornado
    adr x10, status_neg                       // x10 = endereco para salvar o status do caso negativo
    str w1, [x10]                             // grava o status retornado

    adr x9, a_four                            // x9 = endereco do valor 4.0 para o teste max_iter=0
    ldr d0, [x9]                              // d0 = entrada valida para esse teste
    mov w0, wzr                               // w0 = max_iter=0 para disparar erro especifico
    bl sqrt_nr                                // chama a funcao esperando erro de iteracao
after_zero_iter_case:
    adr x10, result_zero_iter                 // x10 = endereco para salvar o resultado do caso max_iter=0
    str d0, [x10]                             // grava o valor retornado
    adr x10, status_zero_iter                 // x10 = endereco para salvar o status do caso max_iter=0
    str w1, [x10]                             // grava o status retornado

    adr x9, status_four                       // x9 = endereco do status do caso positivo
    ldr w10, [x9]                             // carrega o status retornado
    cbnz w10, .fail                           // falha se o status nao for zero

    adr x9, result_four                       // x9 = endereco do resultado do caso positivo
    ldr d0, [x9]                              // carrega a aproximacao calculada
    adr x10, expected_two                     // x10 = endereco do valor esperado 2.0
    ldr d1, [x10]                             // carrega o valor esperado
    fsub d2, d0, d1                           // calcula o erro numerico da aproximacao
    fabs d2, d2                               // toma o valor absoluto do erro
    adr x11, tol                              // x11 = endereco da tolerancia
    ldr d3, [x11]                             // carrega a tolerancia numerica
    fcmp d2, d3                               // compara o erro com a tolerancia
    b.gt .fail                                // falha se o erro for maior que o permitido

    adr x9, status_neg                        // x9 = endereco do status do caso negativo
    ldr w10, [x9]                             // carrega o status retornado
    cmp w10, #1                               // verifica se o codigo de erro foi 1
    b.ne .fail                                // falha se o status estiver incorreto

    adr x9, result_neg                        // x9 = endereco do resultado do caso negativo
    ldr d0, [x9]                              // carrega o retorno da funcao
    fabs d0, d0                               // toma o valor absoluto do retorno
    adr x10, tol                              // x10 = endereco da tolerancia
    ldr d1, [x10]                             // carrega a tolerancia
    fcmp d0, d1                               // verifica se o retorno ficou em zero
    b.gt .fail                                // falha se o retorno estiver fora do esperado

    adr x9, status_zero_iter                  // x9 = endereco do status do caso max_iter=0
    ldr w10, [x9]                             // carrega o status retornado
    cmp w10, #2                               // verifica se o codigo de erro foi 2
    b.ne .fail                                // falha se o status estiver incorreto

    adr x9, result_zero_iter                  // x9 = endereco do resultado do caso max_iter=0
    ldr d0, [x9]                              // carrega o retorno da funcao
    fabs d0, d0                               // toma o valor absoluto do retorno
    adr x10, tol                              // x10 = endereco da tolerancia
    ldr d1, [x10]                             // carrega a tolerancia
    fcmp d0, d1                               // verifica se o retorno ficou em zero
    b.gt .fail                                // falha se o retorno estiver fora do esperado

    mov w0, wzr                               // w0 = exit code 0 para sucesso total
    b .exit                                   // encerra o programa com sucesso

.fail:
    mov w0, #1                                // w0 = exit code 1 para falha em alguma validacao

.exit:
    mov x8, #93                               // x8 = syscall exit do Linux AArch64
    svc #0                                    // encerra o processo com o codigo em w0

.section .note.GNU-stack,"",@progbits
