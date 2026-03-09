// ENUNCIADO COMPLETO (TEXTO INTEGRAL DO HTML, SEM TAGS)
// Exercício 7 Conversão física em double (D registers): Celsius → Fahrenheit
// 
// Tarefa:
// 
// Em instrumentação embarcada, conversões físicas devem preservar precisão para evitar erros cumulativos. Você deve implementar uma função em ponto flutuante double (IEEE-754) para converter Celsius em Fahrenheit, usada em telemetria científica. A rotina deve operar exclusivamente com registradores escalares D e respeitar o PCS: argumentos em FP regs, retorno em FP reg. O objetivo é testar domínio de operações FP básicas, constantes e organização de função. A validação será feita por inspeção do retorno e comparação com valores conhecidos.
// 
// Requisitos Técnicos e Saídas Esperadas:
// 
// - Tipo de dados: double (64-bit) em IEEE-754.
// 
// - Interface: entrada D0 = celsius, saída D0 = fahrenheit.
// 
// - Fórmula: F = C * 9/5 + 32.
// 
// - Pilha / ABI: preservar X30 e quaisquer callee-saved usados; manter alinhamento de stack.
// 
// - Validação: entrada 0.0 → retorno 32.0; entrada 100.0 → retorno 212.0 (verificar em GDB com impressão de double).
//
// Exercicio 7 - Conversao Celsius para Fahrenheit em double
//
// Como funciona:
// 1) Entrada D0 = Celsius.
// 2) Calcula F = C * 9/5 + 32 usando registradores D.
// 3) Retorna D0 = Fahrenheit.

.text
.global _start
.global celsiusToFahrenheit

_start:
    adr x9, c0                    // Endereco de 0.0.
    ldr d0, [x9]                  // D0 = 0.0 C.
    bl celsiusToFahrenheit        // Deve retornar 32.0 F.
    adr x9, result_f0             // Endereco para salvar resultado de 0.0.
    str d0, [x9]                  // Salva resultado.

    adr x9, c100                  // Endereco de 100.0.
    ldr d0, [x9]                  // D0 = 100.0 C.
    bl celsiusToFahrenheit        // Deve retornar 212.0 F.
    adr x9, result_f100           // Endereco para salvar resultado de 100.0.
    str d0, [x9]                  // Salva resultado.

    mov x0, #0                    // Codigo de saida 0.
    mov x8, #93                   // Syscall exit.
    svc #0                        // Encerra.

celsiusToFahrenheit:
    stp x29, x30, [sp, -16]!      // Cria frame e salva LR.
    mov x29, sp                   // Define frame pointer.

    adr x9, const_9_0             // Endereco da constante 9.0.
    ldr d1, [x9]                  // D1 = 9.0.
    adr x9, const_5_0             // Endereco da constante 5.0.
    ldr d2, [x9]                  // D2 = 5.0.
    adr x9, const_32_0            // Endereco da constante 32.0.
    ldr d3, [x9]                  // D3 = 32.0.

    fmul d0, d0, d1               // D0 = C * 9.0.
    fdiv d0, d0, d2               // D0 = C * 9.0 / 5.0.
    fadd d0, d0, d3               // D0 = (C * 9/5) + 32.

    ldp x29, x30, [sp], #16       // Restaura frame e LR.
    ret                           // Retorna Fahrenheit em D0.

.data
const_9_0:
    .double 9.0                   // Constante 9.0.
const_5_0:
    .double 5.0                   // Constante 5.0.
const_32_0:
    .double 32.0                  // Constante 32.0.
c0:
    .double 0.0                   // Caso de teste C=0.0.
c100:
    .double 100.0                 // Caso de teste C=100.0.
result_f0:
    .double 0.0                   // Resultado esperado 32.0.
result_f100:
    .double 0.0                   // Resultado esperado 212.0.
