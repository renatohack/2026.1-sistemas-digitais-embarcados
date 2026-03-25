.data
a_matrix:
    .word 65536, 0, 0, 65536
b_vec:
    .word 65536, 65536
p_vec:
    .word 131072, 196608
out_mode0:
    .word 0, 0
out_mode1:
    .word 0, 0
out_invalid:
    .word 0, 0
expected_mode0:
    .word 131072, 196608
expected_mode1:
    .word 196608, 262144
status_mode0:
    .word 0
status_mode1:
    .word 0
status_invalid:
    .word 0

.text
.global _start

_start:
    mov w0, #0                                // w0 = mode 0 para calcular apenas A*p
    adr x1, a_matrix                          // x1 = endereco da matriz A
    adr x2, b_vec                             // x2 = endereco do vetor b
    adr x3, p_vec                             // x3 = endereco do ponto de entrada p
    adr x4, out_mode0                         // x4 = endereco do vetor de saida do modo 0
    bl affine2d_q16                           // executa a transformacao no modo 0
after_mode0_case:
    adr x9, status_mode0                      // x9 = endereco para salvar o status do modo 0
    str w0, [x9]                              // grava o status retornado

    mov w0, #1                                // w0 = mode 1 para calcular A*p + b
    adr x1, a_matrix                          // x1 = endereco da matriz A
    adr x2, b_vec                             // x2 = endereco do vetor b
    adr x3, p_vec                             // x3 = endereco do ponto de entrada p
    adr x4, out_mode1                         // x4 = endereco do vetor de saida do modo 1
    bl affine2d_q16                           // executa a transformacao no modo 1
after_mode1_case:
    adr x9, status_mode1                      // x9 = endereco para salvar o status do modo 1
    str w0, [x9]                              // grava o status retornado

    mov w0, #99                               // w0 = modo invalido para testar o caso default
    adr x1, a_matrix                          // x1 = endereco da matriz A
    adr x2, b_vec                             // x2 = endereco do vetor b
    adr x3, p_vec                             // x3 = endereco do ponto de entrada p
    adr x4, out_invalid                       // x4 = endereco do vetor de saida para o caso invalido
    bl affine2d_q16                           // chama a funcao esperando erro de modo
after_invalid_mode:
    adr x9, status_invalid                    // x9 = endereco para salvar o status do modo invalido
    str w0, [x9]                              // grava o status retornado

    adr x10, out_mode0                        // x10 = endereco da saida produzida no modo 0
    adr x11, expected_mode0                   // x11 = endereco da saida esperada no modo 0
    mov x12, #2                               // x12 = contador dos 2 elementos do vetor 2D

.check_mode0:
    ldr w13, [x10], #4                        // le o proximo elemento produzido no modo 0
    ldr w14, [x11], #4                        // le o elemento esperado correspondente
    cmp w13, w14                              // compara saida real com saida esperada
    b.ne .fail                                // falha se houver divergencia
    subs x12, x12, #1                         // decrementa o contador de elementos restantes
    b.ne .check_mode0                         // continua enquanto ainda houver elementos a validar

    adr x10, out_mode1                        // x10 = endereco da saida produzida no modo 1
    adr x11, expected_mode1                   // x11 = endereco da saida esperada no modo 1
    mov x12, #2                               // x12 = contador dos 2 elementos do vetor 2D

.check_mode1:
    ldr w13, [x10], #4                        // le o proximo elemento produzido no modo 1
    ldr w14, [x11], #4                        // le o elemento esperado correspondente
    cmp w13, w14                              // compara saida real com saida esperada
    b.ne .fail                                // falha se houver divergencia
    subs x12, x12, #1                         // decrementa o contador de elementos restantes
    b.ne .check_mode1                         // continua enquanto ainda houver elementos a validar

    adr x9, status_mode0                      // x9 = endereco do status do modo 0
    ldr w10, [x9]                             // carrega o status retornado
    cbnz w10, .fail                           // falha se o status nao for zero

    adr x9, status_mode1                      // x9 = endereco do status do modo 1
    ldr w10, [x9]                             // carrega o status retornado
    cbnz w10, .fail                           // falha se o status nao for zero

    adr x9, status_invalid                    // x9 = endereco do status do modo invalido
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
