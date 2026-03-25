.data
coef_ok:
    .word 131072, 196608, 65536
coef_sat:
    .word 2147483647, 2147483647
result_ok:
    .word 0
result_sat:
    .word 0
result_bad_n:
    .word 0
result_null:
    .word 0
status_ok:
    .word 0
status_sat:
    .word 0
status_bad_n:
    .word 0
status_null:
    .word 0

.text
.global _start

_start:
    adr x0, coef_ok                           // x0 = endereco dos coeficientes do caso simples
    mov x1, #3                                // x1 = numero de coeficientes do polinomio simples
    mov w2, #262144                           // w2 = x = 4.0 em Q16.16
    bl poly_horner_q16_sat                    // avalia o polinomio pelo metodo de Horner
after_simple_case:
    adr x9, result_ok                         // x9 = endereco para salvar o resultado do caso simples
    str w0, [x9]                              // grava o valor do polinomio retornado
    adr x9, status_ok                         // x9 = endereco para salvar o status do caso simples
    str w1, [x9]                              // grava o status retornado

    adr x0, coef_sat                          // x0 = endereco dos coeficientes do caso saturado
    mov x1, #2                                // x1 = numero de coeficientes do caso saturado
    mov w2, #131072                           // w2 = x = 2.0 em Q16.16
    bl poly_horner_q16_sat                    // avalia o polinomio esperando saturacao
after_saturation_case:
    adr x9, result_sat                        // x9 = endereco para salvar o resultado saturado
    str w0, [x9]                              // grava o valor retornado
    adr x9, status_sat                        // x9 = endereco para salvar o status do caso saturado
    str w1, [x9]                              // grava o status retornado

    adr x0, coef_ok                           // x0 = coeficientes validos para o teste N=0
    mov x1, xzr                               // x1 = N=0 para disparar erro especifico
    mov w2, #262144                           // w2 = x de teste
    bl poly_horner_q16_sat                    // chama a rotina esperando status 2
after_bad_n_case:
    adr x9, result_bad_n                      // x9 = endereco para salvar o resultado do caso N invalido
    str w0, [x9]                              // grava o valor retornado
    adr x9, status_bad_n                      // x9 = endereco para salvar o status do caso N invalido
    str w1, [x9]                              // grava o status retornado

    mov x0, xzr                               // x0 = ponteiro nulo para testar erro de entrada
    mov x1, #3                                // x1 = numero de coeficientes valido
    mov w2, #262144                           // w2 = x de teste
    bl poly_horner_q16_sat                    // chama a rotina esperando status 1
after_null_case:
    adr x9, result_null                       // x9 = endereco para salvar o resultado do caso nulo
    str w0, [x9]                              // grava o valor retornado
    adr x9, status_null                       // x9 = endereco para salvar o status do caso nulo
    str w1, [x9]                              // grava o status retornado

    adr x9, result_ok                         // x9 = endereco do resultado do caso simples
    ldr w10, [x9]                             // carrega o valor calculado
    mov w11, #2949120                         // w11 = 45.0 em Q16.16, valor esperado
    cmp w10, w11                              // compara o resultado com o esperado
    b.ne .fail                                // falha se o valor estiver incorreto

    adr x9, status_ok                         // x9 = endereco do status do caso simples
    ldr w10, [x9]                             // carrega o status retornado
    cbnz w10, .fail                           // falha se o status nao for zero

    adr x9, result_sat                        // x9 = endereco do resultado do caso saturado
    ldr w10, [x9]                             // carrega o valor calculado
    mov w11, #0x7fffffff                      // w11 = limite maximo esperado apos saturacao
    cmp w10, w11                              // compara o resultado com o limite esperado
    b.ne .fail                                // falha se o valor estiver incorreto

    adr x9, status_sat                        // x9 = endereco do status do caso saturado
    ldr w10, [x9]                             // carrega o status retornado
    cmp w10, #3                               // verifica se a saturacao foi sinalizada
    b.ne .fail                                // falha se o status estiver incorreto

    adr x9, result_bad_n                      // x9 = endereco do resultado do caso N invalido
    ldr w10, [x9]                             // carrega o valor retornado
    cbnz w10, .fail                           // falha se o retorno nao for zero

    adr x9, status_bad_n                      // x9 = endereco do status do caso N invalido
    ldr w10, [x9]                             // carrega o status retornado
    cmp w10, #2                               // verifica se o codigo de erro foi 2
    b.ne .fail                                // falha se o status estiver incorreto

    adr x9, result_null                       // x9 = endereco do resultado do caso nulo
    ldr w10, [x9]                             // carrega o valor retornado
    cbnz w10, .fail                           // falha se o retorno nao for zero

    adr x9, status_null                       // x9 = endereco do status do caso nulo
    ldr w10, [x9]                             // carrega o status retornado
    cmp w10, #1                               // verifica se o codigo de erro foi 1
    b.ne .fail                                // falha se o status estiver incorreto

    mov w0, wzr                               // w0 = exit code 0 para sucesso total
    b .exit                                   // encerra o programa com sucesso

.fail:
    mov w0, #1                                // w0 = exit code 1 para falha em alguma validacao

.exit:
    mov x8, #93                               // x8 = syscall exit do Linux AArch64
    svc #0                                    // encerra o processo com o codigo em w0

.section .note.GNU-stack,"",@progbits
