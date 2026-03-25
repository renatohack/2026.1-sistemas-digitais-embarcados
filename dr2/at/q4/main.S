.data
.balign 8
result_ok:
    .quad 0
result_zero_div:
    .quad 0
result_overflow_guard:
    .quad 0
sat_expected:
    .quad 9223372036854775807
.balign 4
status_ok:
    .word 0
status_zero_div:
    .word 0
status_overflow_guard:
    .word 0

.text
.global _start

_start:
    mov x0, #1000                             // x0 = numerador do caso simples
    mov x1, #10                               // x1 = denominador do caso simples
    bl safe_div_s64                           // chama a divisao segura para o caso normal
after_ok_case:
    adr x9, result_ok                         // x9 = endereco para armazenar o quociente normal
    str x0, [x9]                              // grava o quociente retornado
    adr x9, status_ok                         // x9 = endereco para armazenar o status do caso normal
    str w1, [x9]                              // grava o status retornado

    mov x0, #1000                             // x0 = numerador para o teste de divisor zero
    mov x1, xzr                               // x1 = divisor zero para disparar a politica de erro
    bl safe_div_s64                           // chama a divisao segura esperando saturacao
after_div_zero:
    adr x9, result_zero_div                   // x9 = endereco para armazenar o retorno do divisor zero
    str x0, [x9]                              // grava o valor saturado retornado
    adr x9, status_zero_div                   // x9 = endereco para armazenar o status do divisor zero
    str w1, [x9]                              // grava o status retornado

    mov x0, #1                                // prepara a constante base para montar INT64_MIN
    lsl x0, x0, #63                           // x0 = INT64_MIN
    mov x1, #-1                               // x1 = -1 para testar o overflow especial
    bl safe_div_s64                           // chama a divisao segura esperando saturacao
after_overflow_guard:
    adr x9, result_overflow_guard             // x9 = endereco para armazenar o retorno do caso extremo
    str x0, [x9]                              // grava o valor saturado retornado
    adr x9, status_overflow_guard             // x9 = endereco para armazenar o status do caso extremo
    str w1, [x9]                              // grava o status retornado

    adr x9, result_ok                         // x9 = endereco do resultado do caso simples
    ldr x10, [x9]                             // carrega o quociente calculado
    cmp x10, #100                             // verifica se 1000 / 10 = 100
    b.ne .fail                                // falha se o valor estiver incorreto

    adr x9, status_ok                         // x9 = endereco do status do caso simples
    ldr w10, [x9]                             // carrega o status retornado
    cmp w10, #0                               // verifica se o caso normal retornou sucesso
    b.ne .fail                                // falha se o status estiver incorreto

    adr x9, sat_expected                      // x9 = endereco do valor saturado esperado
    ldr x11, [x9]                             // x11 = constante 0x7FFF_FFFF_FFFF_FFFF

    adr x9, result_zero_div                   // x9 = endereco do retorno para divisor zero
    ldr x10, [x9]                             // carrega o valor retornado
    cmp x10, x11                              // compara com o valor saturado esperado
    b.ne .fail                                // falha se o valor estiver incorreto

    adr x9, status_zero_div                   // x9 = endereco do status do divisor zero
    ldr w10, [x9]                             // carrega o status retornado
    cmp w10, #1                               // verifica se o codigo de erro foi 1
    b.ne .fail                                // falha se o status estiver incorreto

    adr x9, result_overflow_guard             // x9 = endereco do retorno do caso extremo
    ldr x10, [x9]                             // carrega o valor retornado
    cmp x10, x11                              // compara com o valor saturado esperado
    b.ne .fail                                // falha se o valor estiver incorreto

    adr x9, status_overflow_guard             // x9 = endereco do status do caso extremo
    ldr w10, [x9]                             // carrega o status retornado
    cmp w10, #2                               // verifica se o codigo de erro foi 2
    b.ne .fail                                // falha se o status estiver incorreto

    mov w0, wzr                               // w0 = exit code 0 para sucesso total
    b .exit                                   // encerra o programa com sucesso

.fail:
    mov w0, #1                                // w0 = exit code 1 para falha em alguma validacao

.exit:
    mov x8, #93                               // x8 = syscall exit do Linux AArch64
    svc #0                                    // encerra o processo com o codigo em w0

.section .note.GNU-stack,"",@progbits
