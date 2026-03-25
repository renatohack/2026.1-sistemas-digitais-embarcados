.data
input_samples:
    .hword 32767, -32768, 1234, -20000, 0
.balign 4
output_samples:
    .word 0, 0, 0, 0, 0
expected_samples:
    .word 8388607, -8388608, 617000, -8388608, 0
status_primary:
    .word 0
status_zero:
    .word 0
status_null:
    .word 0
dummy_out:
    .word 0

.text
.global _start

_start:
    adr x0, input_samples                     // x0 = endereco do vetor de entrada
    adr x1, output_samples                    // x1 = endereco do vetor de saida
    mov x2, #5                                // x2 = quantidade de amostras
    mov w3, #500                              // w3 = ganho inteiro usado na normalizacao
    bl normalize_saturate_i16_to_i32          // chama a rotina principal de normalizacao
after_extreme_case:
    adr x9, status_primary                    // x9 = endereco para salvar o status do caso principal
    str w0, [x9]                              // grava o status retornado pela funcao

    adr x0, input_samples                     // x0 = mesmo vetor de entrada para testar N=0
    adr x1, dummy_out                         // x1 = saida dummy apenas para validar status
    mov x2, #0                                // x2 = N=0 para disparar erro especifico
    mov w3, #3                                // w3 = ganho arbitrario para o teste
    bl normalize_saturate_i16_to_i32          // chama a rotina para validar o retorno de N=0
after_zero_case:
    adr x9, status_zero                       // x9 = endereco para salvar o status do caso N=0
    str w0, [x9]                              // grava o status retornado

    mov x0, xzr                               // x0 = ponteiro nulo para testar erro de ponteiro
    adr x1, dummy_out                         // x1 = saida dummy para o teste
    mov x2, #1                                // x2 = uma amostra para o caso de ponteiro nulo
    mov w3, #1                                // w3 = ganho arbitrario para o teste
    bl normalize_saturate_i16_to_i32          // chama a rotina para validar erro de ponteiro
after_null_case:
    adr x9, status_null                       // x9 = endereco para salvar o status do caso nulo
    str w0, [x9]                              // grava o status retornado

    adr x10, output_samples                   // x10 = ponteiro para a saida gerada
    adr x11, expected_samples                 // x11 = ponteiro para a saida esperada
    mov x12, #5                               // x12 = contador de comparacao dos 5 elementos

.check_loop:
    ldr w13, [x10], #4                        // le um valor produzido e avanca no vetor de saida
    ldr w14, [x11], #4                        // le o valor esperado correspondente
    cmp w13, w14                              // compara valor produzido com valor esperado
    b.ne .fail                                // falha se houver divergencia
    subs x12, x12, #1                         // decrementa o contador de elementos restantes
    b.ne .check_loop                          // continua enquanto ainda houver elementos para validar

    adr x9, status_primary                    // x9 = endereco do status do caso principal
    ldr w10, [x9]                             // carrega o status do caso principal
    cmp w10, #0                               // verifica se o status foi OK
    b.ne .fail                                // falha se o status nao for 0

    adr x9, status_zero                       // x9 = endereco do status do caso N=0
    ldr w10, [x9]                             // carrega o status do caso N=0
    cmp w10, #1                               // verifica se o retorno foi 1
    b.ne .fail                                // falha se o retorno estiver incorreto

    adr x9, status_null                       // x9 = endereco do status do caso nulo
    ldr w10, [x9]                             // carrega o status do caso nulo
    cmp w10, #2                               // verifica se o retorno foi 2
    b.ne .fail                                // falha se o retorno estiver incorreto

    mov w0, wzr                               // w0 = exit code 0 indicando sucesso total
    b .exit                                   // encerra o programa com sucesso

.fail:
    mov w0, #1                                // w0 = exit code 1 indicando falha em alguma validacao

.exit:
    mov x8, #93                               // x8 = syscall exit no Linux AArch64
    svc #0                                    // encerra o processo com o codigo em w0

.section .note.GNU-stack,"",@progbits
