.data
.balign 8
x_zero:
    .double 0.0
x_one:
    .double 1.0
eps_small:
    .double 0.000000000001
eps_zero:
    .double 0.0
expected_one:
    .double 0.8414709848078965
tol:
    .double 0.000001
result_zero:
    .double 0.0
result_one:
    .double 0.0
result_bad_eps:
    .double 0.0
result_bad_iter:
    .double 0.0
.balign 4
status_zero_case:
    .word 0
status_one_case:
    .word 0
status_bad_eps:
    .word 0
status_bad_iter:
    .word 0

.text
.global _start

_start:
    adr x9, x_zero                            // x9 = endereco do valor x=0
    ldr d0, [x9]                              // d0 = argumento x do seno
    adr x10, eps_small                        // x10 = endereco do epsilon valido
    ldr d1, [x10]                             // d1 = epsilon da aproximacao
    mov w0, #8                                // w0 = maximo de iteracoes para o teste
    bl sin_taylor                             // calcula sin(0) por Taylor
after_zero_case:
    adr x11, result_zero                      // x11 = endereco para guardar o resultado do caso x=0
    str d0, [x11]                             // grava a aproximacao retornada
    adr x11, status_zero_case                 // x11 = endereco para guardar o status do caso x=0
    str w1, [x11]                             // grava o status retornado

    adr x9, x_one                             // x9 = endereco do valor x=1.0
    ldr d0, [x9]                              // d0 = argumento x do seno
    adr x10, eps_small                        // x10 = endereco do epsilon valido
    ldr d1, [x10]                             // d1 = epsilon da aproximacao
    mov w0, #12                               // w0 = numero maior de iteracoes para melhorar a precisao
    bl sin_taylor                             // calcula sin(1.0) por Taylor
after_unit_case:
    adr x11, result_one                       // x11 = endereco para guardar o resultado do caso x=1
    str d0, [x11]                             // grava a aproximacao retornada
    adr x11, status_one_case                  // x11 = endereco para guardar o status do caso x=1
    str w1, [x11]                             // grava o status retornado

    adr x9, x_one                             // x9 = endereco do valor x=1.0 para testar epsilon invalido
    ldr d0, [x9]                              // d0 = argumento x do seno
    adr x10, eps_zero                         // x10 = endereco do epsilon invalido
    ldr d1, [x10]                             // d1 = epsilon zero
    mov w0, #12                               // w0 = iteracoes arbitrarias para o teste
    bl sin_taylor                             // chama a funcao esperando erro de epsilon
after_bad_eps:
    adr x11, result_bad_eps                   // x11 = endereco para guardar o resultado do caso invalido
    str d0, [x11]                             // grava o valor retornado pela funcao
    adr x11, status_bad_eps                   // x11 = endereco para guardar o status do epsilon invalido
    str w1, [x11]                             // grava o status retornado

    adr x9, x_one                             // x9 = endereco do valor x=1.0 para testar max_iter=0
    ldr d0, [x9]                              // d0 = argumento x do seno
    adr x10, eps_small                        // x10 = endereco do epsilon valido
    ldr d1, [x10]                             // d1 = epsilon normal
    mov w0, wzr                               // w0 = max_iter=0 para disparar erro especifico
    bl sin_taylor                             // chama a funcao esperando erro de iteracao
after_bad_iter:
    adr x11, result_bad_iter                  // x11 = endereco para guardar o resultado do caso max_iter=0
    str d0, [x11]                             // grava o valor retornado
    adr x11, status_bad_iter                  // x11 = endereco para guardar o status do caso max_iter=0
    str w1, [x11]                             // grava o status retornado

    adr x9, status_zero_case                  // x9 = endereco do status do caso x=0
    ldr w10, [x9]                             // carrega o status retornado
    cmp w10, #0                               // verifica se o caso x=0 foi bem sucedido
    b.ne .fail                                // falha se o status estiver incorreto

    adr x9, status_one_case                   // x9 = endereco do status do caso x=1
    ldr w10, [x9]                             // carrega o status retornado
    cmp w10, #0                               // verifica se o caso x=1 foi bem sucedido
    b.ne .fail                                // falha se o status estiver incorreto

    adr x9, status_bad_eps                    // x9 = endereco do status do epsilon invalido
    ldr w10, [x9]                             // carrega o status retornado
    cmp w10, #1                               // verifica se o codigo de erro foi 1
    b.ne .fail                                // falha se o status estiver incorreto

    adr x9, status_bad_iter                   // x9 = endereco do status do max_iter invalido
    ldr w10, [x9]                             // carrega o status retornado
    cmp w10, #2                               // verifica se o codigo de erro foi 2
    b.ne .fail                                // falha se o status estiver incorreto

    adr x9, result_zero                       // x9 = endereco do resultado para x=0
    ldr d0, [x9]                              // carrega a aproximacao calculada
    fabs d0, d0                               // toma o valor absoluto do resultado
    adr x10, tol                              // x10 = endereco da tolerancia numerica
    ldr d1, [x10]                             // carrega a tolerancia
    fcmp d0, d1                               // verifica se |sin(0)| ficou abaixo da tolerancia
    b.gt .fail                                // falha se o erro numerico for alto demais

    adr x9, result_one                        // x9 = endereco do resultado para x=1
    ldr d0, [x9]                              // carrega a aproximacao calculada
    adr x10, expected_one                     // x10 = endereco do valor esperado para sin(1)
    ldr d1, [x10]                             // carrega o valor esperado
    fsub d2, d0, d1                           // calcula a diferenca entre aproximado e esperado
    fabs d2, d2                               // toma o valor absoluto do erro
    adr x11, tol                              // x11 = endereco da tolerancia
    ldr d3, [x11]                             // carrega a tolerancia numerica
    fcmp d2, d3                               // verifica se o erro ficou dentro da tolerancia
    b.gt .fail                                // falha se o erro for maior que o permitido

    adr x9, result_bad_eps                    // x9 = endereco do resultado do caso eps invalido
    ldr d0, [x9]                              // carrega o valor retornado pela funcao
    fabs d0, d0                               // toma o valor absoluto do retorno
    adr x10, tol                              // x10 = endereco da tolerancia
    ldr d1, [x10]                             // carrega a tolerancia
    fcmp d0, d1                               // verifica se o retorno ficou efetivamente em zero
    b.gt .fail                                // falha se o retorno diferir do esperado

    adr x9, result_bad_iter                   // x9 = endereco do resultado do caso max_iter invalido
    ldr d0, [x9]                              // carrega o valor retornado pela funcao
    fabs d0, d0                               // toma o valor absoluto do retorno
    adr x10, tol                              // x10 = endereco da tolerancia
    ldr d1, [x10]                             // carrega a tolerancia
    fcmp d0, d1                               // verifica se o retorno ficou efetivamente em zero
    b.gt .fail                                // falha se o retorno diferir do esperado

    mov w0, wzr                               // w0 = exit code 0 indicando sucesso total
    b .exit                                   // encerra o programa com sucesso

.fail:
    mov w0, #1                                // w0 = exit code 1 indicando falha na validacao

.exit:
    mov x8, #93                               // x8 = syscall exit do Linux AArch64
    svc #0                                    // encerra o processo com o codigo em w0

.section .note.GNU-stack,"",@progbits
