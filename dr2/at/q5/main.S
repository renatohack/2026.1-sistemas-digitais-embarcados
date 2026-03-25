.data
result_mode0:
    .word 0
result_mode1:
    .word 0
result_mode2:
    .word 0
result_invalid:
    .word 0
status_mode0:
    .word 0
status_mode1:
    .word 0
status_mode2:
    .word 0
status_invalid:
    .word 0

.text
.global _start

_start:
    mov w0, #0                                // w0 = modo km/h para m/s
    mov w1, #2359296                          // w1 = 36.0 em Q16.16
    bl convert_speed_q16                      // executa a conversao do modo 0
after_mode0:
    adr x9, result_mode0                      // x9 = endereco para salvar o resultado do modo 0
    str w0, [x9]                              // grava o valor convertido retornado
    adr x9, status_mode0                      // x9 = endereco para salvar o status do modo 0
    str w2, [x9]                              // grava o status retornado

    mov w0, #1                                // w0 = modo m/s para km/h
    mov w1, #655360                           // w1 = 10.0 em Q16.16
    bl convert_speed_q16                      // executa a conversao do modo 1
after_mode1:
    adr x9, result_mode1                      // x9 = endereco para salvar o resultado do modo 1
    str w0, [x9]                              // grava o valor convertido retornado
    adr x9, status_mode1                      // x9 = endereco para salvar o status do modo 1
    str w2, [x9]                              // grava o status retornado

    mov w0, #2                                // w0 = modo knots para m/s
    mov w1, #235929600                        // w1 = valor de teste em Q16.16
    bl convert_speed_q16                      // executa a conversao do modo 2
after_mode2:
    adr x9, result_mode2                      // x9 = endereco para salvar o resultado do modo 2
    str w0, [x9]                              // grava o valor convertido retornado
    adr x9, status_mode2                      // x9 = endereco para salvar o status do modo 2
    str w2, [x9]                              // grava o status retornado

    mov w0, #99                               // w0 = modo invalido para testar o caso default
    mov w1, #655360                           // w1 = valor de entrada arbitrario em Q16.16
    bl convert_speed_q16                      // chama a rotina esperando erro de modo
after_invalid_mode:
    adr x9, result_invalid                    // x9 = endereco para salvar o resultado do modo invalido
    str w0, [x9]                              // grava o valor retornado
    adr x9, status_invalid                    // x9 = endereco para salvar o status do modo invalido
    str w2, [x9]                              // grava o status retornado

    adr x9, result_mode0                      // x9 = endereco do resultado do modo 0
    ldr w10, [x9]                             // carrega o valor convertido
    mov w11, #655360                          // w11 = 10.0 em Q16.16, valor esperado
    cmp w10, w11                              // compara resultado calculado com o esperado
    b.ne .fail                                // falha se o valor estiver incorreto

    adr x9, status_mode0                      // x9 = endereco do status do modo 0
    ldr w10, [x9]                             // carrega o status retornado
    cbnz w10, .fail                           // falha se o status nao for zero

    adr x9, result_mode1                      // x9 = endereco do resultado do modo 1
    ldr w10, [x9]                             // carrega o valor convertido
    mov w11, #2359296                         // w11 = 36.0 em Q16.16, valor esperado
    cmp w10, w11                              // compara resultado calculado com o esperado
    b.ne .fail                                // falha se o valor estiver incorreto

    adr x9, status_mode1                      // x9 = endereco do status do modo 1
    ldr w10, [x9]                             // carrega o status retornado
    cbnz w10, .fail                           // falha se o status nao for zero

    adr x9, result_mode2                      // x9 = endereco do resultado do modo 2
    ldr w10, [x9]                             // carrega o valor convertido
    mov w11, #121372672                       // w11 = valor esperado para a conversao de knots
    cmp w10, w11                              // compara resultado calculado com o esperado
    b.ne .fail                                // falha se o valor estiver incorreto

    adr x9, status_mode2                      // x9 = endereco do status do modo 2
    ldr w10, [x9]                             // carrega o status retornado
    cbnz w10, .fail                           // falha se o status nao for zero

    adr x9, result_invalid                    // x9 = endereco do resultado do modo invalido
    ldr w10, [x9]                             // carrega o valor retornado
    cbnz w10, .fail                           // falha se o retorno nao for zero

    adr x9, status_invalid                    // x9 = endereco do status do modo invalido
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
