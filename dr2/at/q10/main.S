.data
input_vec:
    .word 1, 2, 3, 4
output_vec:
    .word 0, 0, 0, 0
expected_vec:
    .word 0, 1, 2, 3
status_ok:
    .word 0
status_bad_w:
    .word 0
status_bad_n:
    .word 0
status_null:
    .word 0

.text
.global _start

_start:
    adr x0, input_vec                         // x0 = endereco do vetor de entrada
    adr x1, output_vec                        // x1 = endereco do vetor de saida
    mov x2, #4                                // x2 = numero de elementos do vetor
    mov w3, #2                                // w3 = tamanho da janela
    bl moving_avg_i32                         // calcula a media movel do caso principal
after_primary_case:
    adr x9, status_ok                         // x9 = endereco para salvar o status do caso principal
    str w0, [x9]                              // grava o status retornado

    adr x0, input_vec                         // x0 = vetor valido para testar janela invalida
    adr x1, output_vec                        // x1 = saida valida para o teste
    mov x2, #4                                // x2 = numero de elementos valido
    mov w3, wzr                               // w3 = janela zero para disparar erro
    bl moving_avg_i32                         // chama a rotina esperando status 3
after_bad_w_case:
    adr x9, status_bad_w                      // x9 = endereco para salvar o status do W invalido
    str w0, [x9]                              // grava o status retornado

    adr x0, input_vec                         // x0 = vetor valido para testar N=0
    adr x1, output_vec                        // x1 = saida valida para o teste
    mov x2, xzr                               // x2 = N=0 para disparar erro especifico
    mov w3, #2                                // w3 = janela valida
    bl moving_avg_i32                         // chama a rotina esperando status 2
after_bad_n_case:
    adr x9, status_bad_n                      // x9 = endereco para salvar o status do N invalido
    str w0, [x9]                              // grava o status retornado

    mov x0, xzr                               // x0 = ponteiro nulo para testar erro de entrada
    adr x1, output_vec                        // x1 = saida valida para o teste
    mov x2, #4                                // x2 = numero de elementos valido
    mov w3, #2                                // w3 = janela valida
    bl moving_avg_i32                         // chama a rotina esperando status 1
after_null_case:
    adr x9, status_null                       // x9 = endereco para salvar o status do caso nulo
    str w0, [x9]                              // grava o status retornado

    adr x10, output_vec                       // x10 = endereco da saida produzida
    adr x11, expected_vec                     // x11 = endereco da saida esperada
    mov x12, #4                               // x12 = contador de elementos do vetor

.check_loop:
    ldr w13, [x10], #4                        // le um elemento produzido e avanca o ponteiro
    ldr w14, [x11], #4                        // le o elemento esperado correspondente
    cmp w13, w14                              // compara os dois valores
    b.ne .fail                                // falha se houver divergencia
    subs x12, x12, #1                         // decrementa o contador de elementos restantes
    b.ne .check_loop                          // continua enquanto ainda houver elementos a validar

    adr x9, status_ok                         // x9 = endereco do status do caso principal
    ldr w10, [x9]                             // carrega o status retornado
    cbnz w10, .fail                           // falha se o status nao for zero

    adr x9, status_bad_w                      // x9 = endereco do status do W invalido
    ldr w10, [x9]                             // carrega o status retornado
    cmp w10, #3                               // verifica se o codigo de erro foi 3
    b.ne .fail                                // falha se o status estiver incorreto

    adr x9, status_bad_n                      // x9 = endereco do status do N invalido
    ldr w10, [x9]                             // carrega o status retornado
    cmp w10, #2                               // verifica se o codigo de erro foi 2
    b.ne .fail                                // falha se o status estiver incorreto

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
