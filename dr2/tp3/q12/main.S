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
// 1) Carrega m=0.1 e v=30000.0 em float, chama ke_f32 e guarda resultado.
// 2) Carrega m=0.1 e v=30000.0 em double, chama ke_f64 e guarda resultado.
// 3) Programa encerra e os valores ficam em memoria para comparacao no GDB.

.text
.global _start
.extern ke_f32
.extern ke_f64

_start:
    adr x9, m32_test              // Endereco de m float.
    ldr s0, [x9]                  // S0 = m (float).
    adr x9, v32_test              // Endereco de v float.
    ldr s1, [x9]                  // S1 = v (float).
    bl ke_f32                     // Calcula E em float.
    adr x9, result_ke_f32         // Endereco para salvar E float.
    str s0, [x9]                  // Salva resultado float.

    adr x9, m64_test              // Endereco de m double.
    ldr d0, [x9]                  // D0 = m (double).
    adr x9, v64_test              // Endereco de v double.
    ldr d1, [x9]                  // D1 = v (double).
    bl ke_f64                     // Calcula E em double.
    adr x9, result_ke_f64         // Endereco para salvar E double.
    str d0, [x9]                  // Salva resultado double.

    mov x0, #0                    // Codigo de saida 0.
    mov x8, #93                   // Syscall exit.
    svc #0                        // Encerra.

.data
m32_test:
    .float 0.1                    // m em float.
v32_test:
    .float 30000.0                // v em float.
m64_test:
    .double 0.1                   // m em double.
v64_test:
    .double 30000.0               // v em double.
result_ke_f32:
    .float 0.0                    // Resultado ke_f32.
result_ke_f64:
    .double 0.0                   // Resultado ke_f64.
