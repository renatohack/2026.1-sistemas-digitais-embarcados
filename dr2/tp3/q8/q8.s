// ENUNCIADO COMPLETO (TEXTO INTEGRAL DO HTML, SEM TAGS)
// Exercício 8 Soma ponderada em float (S registers): Mix de sinais (0.7 A + 0.3 B)
// 
// Tarefa:
// 
// Em processamento de sinais, mixers realizam soma ponderada de duas fontes com coeficientes. Você deve implementar uma função em float32 que combine dois sinais escalares de acordo com pesos fixos. O foco é garantir que o cálculo seja feito em registradores S, que o resultado seja retornado corretamente e que o código seja estável em presença de valores pequenos, grandes e negativos. Este exercício testa domínio de FP escalar e precisão em float32, além de disciplina de função.
// 
// Requisitos Técnicos e Saídas Esperadas:
// 
// - Tipo de dados: float (32-bit).
// 
// - Interface: entrada S0=A, S1=B; saída S0=mix.
// 
// - Fórmula: mix = 0.7A + 0.3B.
// 
// - Pilha / ABI: preservar X30; preservar callee-saved se usados; stack alinhado.
// 
// - Validação: A=10.0, B=0.0 → 7.0; A=0.0, B=10.0 → 3.0; validar em GDB.
//
// Exercicio 8 - Soma ponderada em float32
//
// Como funciona:
// 1) Entrada S0=A e S1=B.
// 2) Calcula mix = 0.7*A + 0.3*B em registradores S.
// 3) Retorna S0=mix.

.text
.global _start
.global mixSignals

_start:
    adr x9, a1                    // Endereco de A=10.0 no teste 1.
    ldr s0, [x9]                  // S0 = 10.0.
    adr x9, b1                    // Endereco de B=0.0 no teste 1.
    ldr s1, [x9]                  // S1 = 0.0.
    bl mixSignals                 // Esperado: 7.0.
    adr x9, result_mix1           // Endereco para salvar resultado 1.
    str s0, [x9]                  // Salva mix do teste 1.

    adr x9, a2                    // Endereco de A=0.0 no teste 2.
    ldr s0, [x9]                  // S0 = 0.0.
    adr x9, b2                    // Endereco de B=10.0 no teste 2.
    ldr s1, [x9]                  // S1 = 10.0.
    bl mixSignals                 // Esperado: 3.0.
    adr x9, result_mix2           // Endereco para salvar resultado 2.
    str s0, [x9]                  // Salva mix do teste 2.

after_results_saved:
    mov x0, #0                    // Codigo de saida 0.
    mov x8, #93                   // Syscall exit.
    svc #0                        // Encerra.

mixSignals:
    stp x29, x30, [sp, -16]!      // Cria frame e salva LR.
    mov x29, sp                   // Define frame pointer.

    adr x9, const_0_7             // Endereco da constante 0.7.
    ldr s2, [x9]                  // S2 = 0.7.
    adr x9, const_0_3             // Endereco da constante 0.3.
    ldr s3, [x9]                  // S3 = 0.3.

    fmul s2, s0, s2               // S2 = 0.7 * A.
    fmul s3, s1, s3               // S3 = 0.3 * B.
    fadd s0, s2, s3               // S0 = (0.7*A) + (0.3*B).

    ldp x29, x30, [sp], #16       // Restaura frame e LR.
    ret                           // Retorna mix em S0.

.data
const_0_7:
    .float 0.7                    // Peso de A.
const_0_3:
    .float 0.3                    // Peso de B.
a1:
    .float 10.0                   // Teste 1: A=10.0.
b1:
    .float 0.0                    // Teste 1: B=0.0.
a2:
    .float 0.0                    // Teste 2: A=0.0.
b2:
    .float 10.0                   // Teste 2: B=10.0.
result_mix1:
    .float 0.0                    // Resultado esperado 7.0.
result_mix2:
    .float 0.0                    // Resultado esperado 3.0.
