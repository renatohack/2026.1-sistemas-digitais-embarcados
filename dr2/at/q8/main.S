.data
.balign 8
signal:
    .double 0.0, 1.0, 2.0
dt_one:
    .double 1.0
dt_zero:
    .double 0.0
expected_integral:
    .double 2.0
tol:
    .double 0.000001
result_ok:
    .double 0.0
result_bad_n:
    .double 0.0
result_bad_dt:
    .double 0.0
result_null:
    .double 0.0
.balign 4
status_ok:
    .word 0
status_bad_n:
    .word 0
status_bad_dt:
    .word 0
status_null:
    .word 0

.text
.global _start

_start:
    adr x0, signal                            // x0 = endereco do vetor de amostras do caso principal
    mov x1, #3                                // x1 = quantidade de amostras do caso principal
    adr x9, dt_one                            // x9 = endereco do dt valido
    ldr d0, [x9]                              // d0 = passo de integracao
    bl trapz_energy_f64                       // calcula a integral pelo metodo do trapezio
after_primary_case:
    adr x10, result_ok                        // x10 = endereco para salvar a integral calculada
    str d0, [x10]                             // grava o resultado retornado
    adr x10, status_ok                        // x10 = endereco para salvar o status do caso principal
    str w0, [x10]                             // grava o status retornado

    adr x0, signal                            // x0 = vetor valido para o teste N<2
    mov x1, #1                                // x1 = numero insuficiente de amostras
    adr x9, dt_one                            // x9 = endereco do dt valido
    ldr d0, [x9]                              // d0 = passo de integracao
    bl trapz_energy_f64                       // chama a funcao esperando status 2
after_bad_n_case:
    adr x10, result_bad_n                     // x10 = endereco para salvar o resultado do caso N invalido
    str d0, [x10]                             // grava o retorno da funcao
    adr x10, status_bad_n                     // x10 = endereco para salvar o status do caso N invalido
    str w0, [x10]                             // grava o status retornado

    adr x0, signal                            // x0 = vetor valido para o teste de dt invalido
    mov x1, #3                                // x1 = quantidade de amostras suficiente
    adr x9, dt_zero                           // x9 = endereco do dt zero
    ldr d0, [x9]                              // d0 = passo invalido
    bl trapz_energy_f64                       // chama a funcao esperando status 3
after_bad_dt_case:
    adr x10, result_bad_dt                    // x10 = endereco para salvar o resultado do caso dt invalido
    str d0, [x10]                             // grava o retorno da funcao
    adr x10, status_bad_dt                    // x10 = endereco para salvar o status do caso dt invalido
    str w0, [x10]                             // grava o status retornado

    mov x0, xzr                               // x0 = ponteiro nulo para testar erro de entrada
    mov x1, #3                                // x1 = numero valido de amostras
    adr x9, dt_one                            // x9 = endereco do dt valido
    ldr d0, [x9]                              // d0 = passo de integracao
    bl trapz_energy_f64                       // chama a funcao esperando status 1
after_null_case:
    adr x10, result_null                      // x10 = endereco para salvar o resultado do caso nulo
    str d0, [x10]                             // grava o retorno da funcao
    adr x10, status_null                      // x10 = endereco para salvar o status do caso nulo
    str w0, [x10]                             // grava o status retornado

    adr x9, status_ok                         // x9 = endereco do status do caso principal
    ldr w10, [x9]                             // carrega o status retornado
    cbnz w10, .fail                           // falha se o status nao for zero

    adr x9, result_ok                         // x9 = endereco da integral calculada
    ldr d0, [x9]                              // carrega o valor retornado
    adr x10, expected_integral                // x10 = endereco da integral esperada
    ldr d1, [x10]                             // carrega o valor esperado
    fsub d2, d0, d1                           // calcula o erro numerico da integral
    fabs d2, d2                               // toma o valor absoluto do erro
    adr x11, tol                              // x11 = endereco da tolerancia
    ldr d3, [x11]                             // carrega a tolerancia numerica
    fcmp d2, d3                               // compara o erro com a tolerancia
    b.gt .fail                                // falha se o erro for maior que o permitido

    adr x9, status_bad_n                      // x9 = endereco do status do caso N invalido
    ldr w10, [x9]                             // carrega o status retornado
    cmp w10, #2                               // verifica se o codigo de erro foi 2
    b.ne .fail                                // falha se o status estiver incorreto

    adr x9, result_bad_n                      // x9 = endereco do resultado do caso N invalido
    ldr d0, [x9]                              // carrega o retorno da funcao
    fabs d0, d0                               // toma o valor absoluto do retorno
    adr x10, tol                              // x10 = endereco da tolerancia
    ldr d1, [x10]                             // carrega a tolerancia
    fcmp d0, d1                               // verifica se o retorno ficou em zero
    b.gt .fail                                // falha se o retorno estiver fora do esperado

    adr x9, status_bad_dt                     // x9 = endereco do status do caso dt invalido
    ldr w10, [x9]                             // carrega o status retornado
    cmp w10, #3                               // verifica se o codigo de erro foi 3
    b.ne .fail                                // falha se o status estiver incorreto

    adr x9, result_bad_dt                     // x9 = endereco do resultado do caso dt invalido
    ldr d0, [x9]                              // carrega o retorno da funcao
    fabs d0, d0                               // toma o valor absoluto do retorno
    adr x10, tol                              // x10 = endereco da tolerancia
    ldr d1, [x10]                             // carrega a tolerancia
    fcmp d0, d1                               // verifica se o retorno ficou em zero
    b.gt .fail                                // falha se o retorno estiver fora do esperado

    adr x9, status_null                       // x9 = endereco do status do caso nulo
    ldr w10, [x9]                             // carrega o status retornado
    cmp w10, #1                               // verifica se o codigo de erro foi 1
    b.ne .fail                                // falha se o status estiver incorreto

    adr x9, result_null                       // x9 = endereco do resultado do caso nulo
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
