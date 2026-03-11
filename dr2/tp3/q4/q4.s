// ENUNCIADO COMPLETO (TEXTO INTEGRAL DO HTML, SEM TAGS)
// Exercício 4 Recursão controlada e quadro de ativação (factorial64)
// 
// Tarefa:
// 
// Em sistemas críticos, recursão raramente é usada em tempo real, mas é uma ferramenta didática valiosa para testar disciplina de pilha e preservação de estado. Você deve implementar uma função recursiva de fatorial para validar prólogo/epílogo, preservação do link register e manutenção de parâmetros em chamadas sucessivas. A função será utilizada em uma rotina offline de calibração onde n é pequeno e limitado. O desafio é garantir que cada chamada construa seu quadro de ativação corretamente e que o retorno finalize com o valor esperado, sem corromper registradores não voláteis do chamador.
// 
// Requisitos Técnicos e Saídas Esperadas:
// 
// - Tipo de dados: inteiro unsigned 64-bit.
// 
// - Interface: entrada X0 = n, saída X0 = n!.
// 
// - Restrição: assumir 0 ≤ n ≤ 20 (cabe em 64 bits).
// 
// - Pilha / ABI: cada frame deve preservar X30; se usar X19–X28, preservar. Manter alinhamento de pilha conforme PCS.
// 
// - Validação: em GDB, factorial64(10) retorna 3628800 em X0. Para n=0, retorna 1.
//
// Exercicio 4 - factorial64 recursivo
//
// Como funciona:
// 1) Recebe n em X0.
// 2) Se n <= 1, retorna 1.
// 3) Se n > 1, chama factorial64(n-1) recursivamente.
// 4) Multiplica o retorno por n e devolve em X0.
//
// O codigo cria frame em cada chamada para manter LR e contexto corretos.

.text
.global _start
.global factorial64

_start:
    mov x0, #10                   // Define n=10 para teste principal.
    bl factorial64                // Calcula 10!.
    adr x1, result_n10            // Endereco para salvar resultado de n=10.
    str x0, [x1]                  // Salva 3628800 em memoria.

    mov x0, #0                    // Define n=0 para teste de borda.
    bl factorial64                // Calcula 0!.
    adr x1, result_n0             // Endereco para salvar resultado de n=0.
    str x0, [x1]                  // Salva 1 em memoria.

after_results_saved:
    mov x0, #0                    // Codigo de saida 0.
    mov x8, #93                   // Syscall exit.
    svc #0                        // Encerra programa.

factorial64:
    stp x29, x30, [sp, -16]!      // Cria frame e salva LR.
    mov x29, sp                   // Define frame pointer.
    stp x19, x20, [sp, -16]!      // Salva callee-saved usados.

    mov x19, x0                   // Guarda n atual para usar apos a chamada recursiva.
    cmp x0, #1                    // Compara n com 1.
    bhi recurse_case              // Se n > 1, entra no caso recursivo.

    mov x0, #1                    // Caso base: 0! e 1! retornam 1.
    b end_factorial               // Vai para epilogo.

recurse_case:
    sub x0, x19, #1               // Prepara argumento n-1.
    bl factorial64                // Chama recursivamente factorial64(n-1).
    mul x0, x0, x19               // Multiplica retorno por n atual.

end_factorial:
    ldp x19, x20, [sp], #16       // Restaura callee-saved.
    ldp x29, x30, [sp], #16       // Restaura frame e LR.
    ret                           // Retorna ao chamador.

.data
result_n10:
    .quad 0                       // Guarda resultado de factorial64(10).
result_n0:
    .quad 0                       // Guarda resultado de factorial64(0).
