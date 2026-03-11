// ENUNCIADO COMPLETO (TEXTO INTEGRAL DO HTML, SEM TAGS)
// Exercício 9 Aproximação de seno por Série de Taylor (double, 3 termos)
// 
// Tarefa:
// 
// Em navegação inercial, aproximações de funções trigonométricas são usadas quando latência e dependência de bibliotecas são restritas. Você deve implementar uma função sin_approx em double que calcula uma aproximação por Série de Taylor com 3 termos ao redor de zero: sin(x) ≈ x - x³/3! + x⁵/5!. O objetivo é testar operações FP, ordem de avaliação e conversão de expressão algébrica para Assembly, mantendo coerência numérica. A função deve ser modular e auditável, com retorno determinístico para entradas pequenas. A validação inclui comparação com valores de referência em pontos conhecidos.
// 
// Requisitos Técnicos e Saídas Esperadas:
// 
// - Tipo de dados: double.
// 
// - Interface: entrada D0=x, saída D0=sin_approx(x).
// 
// - Cálculo: implementar exatamente 3 termos: x - x^3/6 + x^5/120.
// 
// - Pilha / ABI: preservar X30 e callee-saved usados; stack alinhado.
// 
// - Validação: para x=0.0, retorno 0.0; para x=0.1, retorno próximo de 0.099833... com erro absoluto < 1e-6 (avaliado via GDB/printf auxiliar permitido no chamador, se desejado).
//
// Exercicio 9 - Aproximacao de seno (3 termos da serie de Taylor)
//
// Como funciona:
// 1) Entrada D0 = x.
// 2) Calcula sin_approx(x) = x - x^3/6 + x^5/120.
// 3) Usa somente 3 termos, exatamente como o enunciado pede.
// 4) Retorna D0 com a aproximacao.

.text
.global _start
.global sin_approx

_start:
    adr x9, x_zero                // Endereco do teste x=0.0.
    ldr d0, [x9]                  // D0 = 0.0.
    bl sin_approx                 // Esperado: 0.0.
    adr x9, result_x0             // Endereco para salvar resultado de x=0.0.
    str d0, [x9]                  // Salva resultado.

    adr x9, x_point_one           // Endereco do teste x=0.1.
    ldr d0, [x9]                  // D0 = 0.1.
    bl sin_approx                 // Esperado: proximo de 0.099833...
    adr x9, result_x01            // Endereco para salvar resultado de x=0.1.
    str d0, [x9]                  // Salva resultado.

after_results_saved:
    mov x0, #0                    // Codigo de saida 0.
    mov x8, #93                   // Syscall exit.
    svc #0                        // Encerra.

sin_approx:
    stp x29, x30, [sp, -16]!      // Cria frame e salva LR.
    mov x29, sp                   // Define frame pointer.

    fmov d1, d0                   // D1 = x (termo linear).
    fmul d2, d0, d0               // D2 = x^2.
    fmul d3, d2, d0               // D3 = x^3.
    fmul d4, d3, d2               // D4 = x^5.

    adr x9, const_6_0             // Endereco da constante 6.0.
    ldr d5, [x9]                  // D5 = 6.0.
    adr x9, const_120_0           // Endereco da constante 120.0.
    ldr d6, [x9]                  // D6 = 120.0.

    fdiv d3, d3, d5               // D3 = x^3 / 6.
    fdiv d4, d4, d6               // D4 = x^5 / 120.

    fsub d0, d1, d3               // D0 = x - x^3/6.
    fadd d0, d0, d4               // D0 = x - x^3/6 + x^5/120.

    ldp x29, x30, [sp], #16       // Restaura frame e LR.
    ret                           // Retorna aproximacao em D0.

.data
const_6_0:
    .double 6.0                   // 3!.
const_120_0:
    .double 120.0                 // 5!.
x_zero:
    .double 0.0                   // Caso de teste x=0.0.
x_point_one:
    .double 0.1                   // Caso de teste x=0.1.
result_x0:
    .double 0.0                   // Resultado para x=0.0.
result_x01:
    .double 0.0                   // Resultado para x=0.1.
