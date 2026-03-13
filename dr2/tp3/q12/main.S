// ENUNCIADO COMPLETO (TEXTO INTEGRAL DO HTML, SEM TAGS)
// Exercício 12 Comparação de precisão: float vs double em fórmula física (energia cinética)
// 
// Tarefa:
// 
// Em sistemas de sensoriamento e controle, pequenas perdas de precisão podem induzir erro acumulado, especialmente quando cálculos são iterados. Você deve implementar duas funções: uma em float32 e outra em double64 para calcular energia cinética E = 0.5 * m * v^2. O chamador deverá executar ambas com a mesma entrada e comparar os resultados. O objetivo é evidenciar diferenças de arredondamento e representar claramente, por meio do retorno e inspeção, como a escolha do formato afeta o resultado. A implementação deve respeitar ABI de FP e ser modular, permitindo linkagem de um pequeno harness de teste.
// 
// Requisitos Técnicos e Saídas Esperadas:
// 
// - Modularidade: ke_f32 e ke_f64 em lib.S; main.S como harness de teste.
// 
// - Tipo de dados: float para ke_f32, double para ke_f64.
// 
// - Interface:
// 
// - ke_f32: entrada S0=m, S1=v; saída S0=E
// 
// - ke_f64: entrada D0=m, D1=v; saída D0=E.
// 
// - Validação: use m=0.1 e v=30000.0 como caso de teste e compare E_f32 vs E_f64 em GDB; relatório deve registrar a diferença observada (erro absoluto ou relativo).
// 
// - Pilha / ABI: preservar X30 e callee-saved usados; stack alinhado.
//
// Exercicio 12 - Harness para comparar ke_f32 e ke_f64
//
// Como funciona:
// 1) Executa o caso pedido no enunciado: m=0.1 e v=30000.0.
// 2) Executa um segundo caso: m=0.1 e v=123456.789.
// 3) Salva os quatro resultados em memoria para comparacao no GDB.

.text
.global _start
.extern ke_f32
.extern ke_f64

_start:
    adr x9, m32_test_case1        // Endereco de m float do caso 1.
    ldr s0, [x9]                  // S0 = m (float).
    adr x9, v32_test_case1        // Endereco de v float do caso 1.
    ldr s1, [x9]                  // S1 = v (float).
    bl ke_f32                     // Calcula E em float para o caso 1.
    adr x9, result_ke_f32_case1   // Endereco para salvar E float do caso 1.
    str s0, [x9]                  // Salva resultado float do caso 1.

    adr x9, m64_test_case1        // Endereco de m double do caso 1.
    ldr d0, [x9]                  // D0 = m (double).
    adr x9, v64_test_case1        // Endereco de v double do caso 1.
    ldr d1, [x9]                  // D1 = v (double).
    bl ke_f64                     // Calcula E em double para o caso 1.
    adr x9, result_ke_f64_case1   // Endereco para salvar E double do caso 1.
    str d0, [x9]                  // Salva resultado double do caso 1.

    adr x9, m32_test_case2        // Endereco de m float do caso 2.
    ldr s0, [x9]                  // S0 = m (float).
    adr x9, v32_test_case2        // Endereco de v float do caso 2.
    ldr s1, [x9]                  // S1 = v (float).
    bl ke_f32                     // Calcula E em float para o caso 2.
    adr x9, result_ke_f32_case2   // Endereco para salvar E float do caso 2.
    str s0, [x9]                  // Salva resultado float do caso 2.

    adr x9, m64_test_case2        // Endereco de m double do caso 2.
    ldr d0, [x9]                  // D0 = m (double).
    adr x9, v64_test_case2        // Endereco de v double do caso 2.
    ldr d1, [x9]                  // D1 = v (double).
    bl ke_f64                     // Calcula E em double para o caso 2.
    adr x9, result_ke_f64_case2   // Endereco para salvar E double do caso 2.
    str d0, [x9]                  // Salva resultado double do caso 2.

after_results_saved:
    mov x0, #0                    // Codigo de saida 0.
    mov x8, #93                   // Syscall exit.
    svc #0                        // Encerra.

.data
m32_test_case1:
    .float 0.1                    // m em float do caso pedido no enunciado.
v32_test_case1:
    .float 30000.0                // v em float do caso pedido no enunciado.
m64_test_case1:
    .double 0.1                   // m em double do caso pedido no enunciado.
v64_test_case1:
    .double 30000.0               // v em double do caso pedido no enunciado.
result_ke_f32_case1:
    .float 0.0                    // Resultado ke_f32 do caso 1.
result_ke_f64_case1:
    .double 0.0                   // Resultado ke_f64 do caso 1.

m32_test_case2:
    .float 0.1                    // m em float do caso adicional.
v32_test_case2:
    .float 123456.789             // v em float do caso adicional.
m64_test_case2:
    .double 0.1                   // m em double do caso adicional.
v64_test_case2:
    .double 123456.789            // v em double do caso adicional.
result_ke_f32_case2:
    .float 0.0                    // Resultado ke_f32 do caso 2.
result_ke_f64_case2:
    .double 0.0                   // Resultado ke_f64 do caso 2.
