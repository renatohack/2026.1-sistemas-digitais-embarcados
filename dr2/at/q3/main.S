.data
vec_a_ok:
    .word 1, -2, 3
vec_b_ok:
    .word 4, 5, 6
vec_big_a:
    .word 2147483647, 2147483647, 2147483647
vec_big_b:
    .word 2147483647, 2147483647, 2147483647
.balign 8
acc_ok:
    .quad 0
acc_overflow:
    .quad 0
expected_overflow_acc:
    .quad 9223372028264841218
.balign 4
status_ok:
    .word 0
status_overflow:
    .word 0
status_zero:
    .word 0
status_null:
    .word 0

.text
.global _start

_start:
    adr x0, vec_a_ok                          // x0 = endereco do vetor A do caso simples
    adr x1, vec_b_ok                          // x1 = endereco do vetor B do caso simples
    mov x2, #3                                // x2 = numero de elementos dos vetores
    bl dot_i32_checked                        // calcula o produto escalar do caso simples
after_ok_case:
    adr x9, acc_ok                            // x9 = endereco para armazenar o acumulador do caso simples
    str x0, [x9]                              // grava a soma retornada em x0
    adr x9, status_ok                         // x9 = endereco para armazenar o status do caso simples
    str w1, [x9]                              // grava o status retornado em w1

    adr x0, vec_big_a                         // x0 = endereco do vetor A do caso de overflow
    adr x1, vec_big_b                         // x1 = endereco do vetor B do caso de overflow
    mov x2, #3                                // x2 = numero de elementos do caso de overflow
    bl dot_i32_checked                        // calcula o produto escalar esperando early-exit
after_overflow_case:
    adr x9, acc_overflow                      // x9 = endereco para armazenar o acumulador antes do overflow
    str x0, [x9]                              // grava a soma acumulada retornada
    adr x9, status_overflow                   // x9 = endereco para armazenar o status do overflow
    str w1, [x9]                              // grava o status retornado

    adr x0, vec_a_ok                          // x0 = vetor valido para o teste de N=0
    adr x1, vec_b_ok                          // x1 = outro vetor valido para o teste
    mov x2, #0                                // x2 = zero elementos para disparar o erro
    bl dot_i32_checked                        // chama a funcao esperando status 1
after_zero_case:
    adr x9, status_zero                       // x9 = endereco para armazenar o status do caso N=0
    str w1, [x9]                              // grava o status retornado

    mov x0, xzr                               // x0 = ponteiro nulo para testar erro de ponteiro
    adr x1, vec_b_ok                          // x1 = vetor valido para complementar o teste
    mov x2, #1                                // x2 = um elemento para o teste de ponteiro nulo
    bl dot_i32_checked                        // chama a funcao esperando status 2
after_null_case:
    adr x9, status_null                       // x9 = endereco para armazenar o status do caso nulo
    str w1, [x9]                              // grava o status retornado

    adr x9, acc_ok                            // x9 = endereco do acumulador do caso simples
    ldr x10, [x9]                             // carrega o valor calculado
    cmp x10, #12                              // verifica se 1*4 + (-2)*5 + 3*6 = 12
    b.ne .fail                                // falha se o resultado estiver incorreto

    adr x9, status_ok                         // x9 = endereco do status do caso simples
    ldr w10, [x9]                             // carrega o status do caso simples
    cmp w10, #0                               // verifica se o caso simples terminou com sucesso
    b.ne .fail                                // falha se o status estiver incorreto

    adr x9, status_overflow                   // x9 = endereco do status do caso de overflow
    ldr w10, [x9]                             // carrega o status retornado
    cmp w10, #3                               // verifica se o overflow foi sinalizado corretamente
    b.ne .fail                                // falha se o status estiver incorreto

    adr x9, acc_overflow                      // x9 = endereco do acumulador do caso de overflow
    ldr x10, [x9]                             // carrega a soma acumulada antes da interrupcao
    adr x11, expected_overflow_acc            // x11 = endereco do valor esperado
    ldr x12, [x11]                            // carrega o valor esperado
    cmp x10, x12                              // compara acumulador real com acumulador esperado
    b.ne .fail                                // falha se os valores divergirem

    adr x9, status_zero                       // x9 = endereco do status do caso N=0
    ldr w10, [x9]                             // carrega o status retornado
    cmp w10, #1                               // verifica se o erro N=0 foi sinalizado
    b.ne .fail                                // falha se o status estiver incorreto

    adr x9, status_null                       // x9 = endereco do status do caso de ponteiro nulo
    ldr w10, [x9]                             // carrega o status retornado
    cmp w10, #2                               // verifica se o erro de ponteiro foi sinalizado
    b.ne .fail                                // falha se o status estiver incorreto

    mov w0, wzr                               // w0 = exit code 0 para sucesso total
    b .exit                                   // encerra o programa com sucesso

.fail:
    mov w0, #1                                // w0 = exit code 1 para falha em alguma validacao

.exit:
    mov x8, #93                               // x8 = syscall exit do Linux AArch64
    svc #0                                    // encerra o processo com o codigo em w0

.section .note.GNU-stack,"",@progbits
