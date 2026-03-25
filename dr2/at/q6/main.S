.data
test_string:
    .ascii "HeLLo!\0"
expected_string:
    .ascii "hello!\0"
.balign 4
count_result:
    .word 0
status_result:
    .word 0
count_null:
    .word 0
status_null:
    .word 0

.text
.global _start

_start:
    adr x0, test_string                       // x0 = endereco da string que sera convertida
    bl to_lower_ascii_inplace                 // chama a rotina de lowercase in-place
after_string_case:
    adr x9, count_result                      // x9 = endereco para salvar a quantidade convertida
    str w0, [x9]                              // grava o contador retornado pela funcao
    adr x9, status_result                     // x9 = endereco para salvar o status do caso principal
    str w1, [x9]                              // grava o status retornado

    mov x0, xzr                               // x0 = ponteiro nulo para testar erro de entrada
    bl to_lower_ascii_inplace                 // chama a rotina esperando status 1
after_null_case:
    adr x9, count_null                        // x9 = endereco para salvar o contador do caso nulo
    str w0, [x9]                              // grava o contador retornado
    adr x9, status_null                       // x9 = endereco para salvar o status do caso nulo
    str w1, [x9]                              // grava o status retornado

    adr x10, test_string                      // x10 = endereco da string modificada
    adr x11, expected_string                  // x11 = endereco da string esperada

.compare_loop:
    ldrb w12, [x10], #1                       // le um byte da string produzida e avanca o ponteiro
    ldrb w13, [x11], #1                       // le o byte correspondente da string esperada
    cmp w12, w13                              // compara os bytes atual e esperado
    b.ne .fail                                // falha se houver qualquer divergencia
    cbz w12, .check_status                    // encerra a comparacao ao encontrar o terminador nulo
    b .compare_loop                           // continua comparando os proximos bytes

.check_status:
    adr x9, count_result                      // x9 = endereco do contador do caso principal
    ldr w10, [x9]                             // carrega a quantidade de conversoes realizadas
    cmp w10, #3                               // verifica se exatamente 3 letras foram convertidas
    b.ne .fail                                // falha se o contador estiver incorreto

    adr x9, status_result                     // x9 = endereco do status do caso principal
    ldr w10, [x9]                             // carrega o status retornado
    cbnz w10, .fail                           // falha se o status nao for zero

    adr x9, count_null                        // x9 = endereco do contador do caso nulo
    ldr w10, [x9]                             // carrega o contador retornado
    cbnz w10, .fail                           // falha se o contador do erro nao for zero

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
