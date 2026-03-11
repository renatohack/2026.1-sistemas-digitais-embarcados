// ENUNCIADO COMPLETO (TEXTO INTEGRAL DO HTML, SEM TAGS)
// Exercício 6 Divisão inteira segura (SDIV/UDIV) com fallback determinístico
// 
// Tarefa:
// 
// Em firmware de navegação e controle, razões e normalizações são comuns, mas divisão por zero é um risco crítico. Você deve implementar uma função de divisão segura que suporte assinada e não assinada, retornando um resultado e um código de status. O chamador não pode aceitar traps ou comportamento indefinido: quando o denominador for zero, a função deve retornar um valor de fallback e sinalizar erro. O desafio é implementar uma interface robusta, respeitar ABI e garantir que o estado do chamador permanece intacto. A validação cobre casos normais e casos de borda.
// 
// Requisitos Técnicos e Saídas Esperadas:
// 
// - Tipo de dados: inteiros 64-bit (signed e unsigned).
// 
// - Interface:
// 
// - entrada: X0=numerador, X1=denominador, X2=mode (0=unsigned, 1=signed)
// 
// - saída: X0=quociente, W1=status (0=OK, 1=DIV0).
// 
// - Cálculo: usar UDIV quando mode=0, SDIV quando mode=1.
// 
// - Borda: se X1==0, retornar X0=0 e W1=1.
// 
// - Pilha / ABI: preservar X30 e quaisquer X19–X28 usados.
// 
// - Validação: safeDiv(100,4,0) retorna 25 e status 0; safeDiv(100,0,0) retorna 0 e status 1.
//
// Exercicio 6 - safeDiv com UDIV/SDIV e fallback para divisao por zero
//
// Como funciona:
// 1) Entrada: X0=numerador, X1=denominador, X2=mode.
//    mode=0 usa UDIV (unsigned), mode=1 usa SDIV (signed).
// 2) Se denominador for zero, retorna X0=0 e W1=1.
// 3) Se divisao normal, retorna quociente em X0 e status W1=0.

.text
.global _start
.global safeDiv

_start:
    mov x0, #100                  // numerador do caso normal.
    mov x1, #4                    // denominador do caso normal.
    mov x2, #0                    // modo unsigned.
    bl safeDiv                    // Esperado: quociente 25, status 0.

    adr x3, q_ok                  // Endereco para salvar quociente do caso normal.
    str x0, [x3]                  // Salva quociente.
    adr x3, s_ok                  // Endereco para salvar status do caso normal.
    str w1, [x3]                  // Salva status.

    mov x0, #100                  // numerador do caso DIV0.
    mov x1, #0                    // denominador zero.
    mov x2, #0                    // modo unsigned.
    bl safeDiv                    // Esperado: quociente 0, status 1.

    adr x3, q_div0                // Endereco para salvar quociente do caso DIV0.
    str x0, [x3]                  // Salva quociente.
    adr x3, s_div0                // Endereco para salvar status do caso DIV0.
    str w1, [x3]                  // Salva status.

after_results_saved:
    mov x0, #0                    // Codigo de saida 0.
    mov x8, #93                   // Syscall exit.
    svc #0                        // Encerra.

safeDiv:
    stp x29, x30, [sp, -16]!      // Cria frame e salva LR.
    mov x29, sp                   // Define frame pointer.

    cbz x1, div_by_zero           // Se denominador == 0, vai para fallback.

    cmp x2, #1                    // Verifica se modo e signed.
    beq do_sdiv                   // Se mode==1, usa SDIV.

    udiv x0, x0, x1               // mode==0: quociente unsigned.
    mov w1, #0                    // Status OK.
    b end_safe_div                // Vai para epilogo.

do_sdiv:
    sdiv x0, x0, x1               // mode==1: quociente signed.
    mov w1, #0                    // Status OK.
    b end_safe_div                // Vai para epilogo.

div_by_zero:
    mov x0, #0                    // Fallback de quociente para DIV0.
    mov w1, #1                    // Status DIV0.

end_safe_div:
    ldp x29, x30, [sp], #16       // Restaura frame e LR.
    ret                           // Retorna com quociente e status.

.data
q_ok:
    .quad 0                       // Resultado do caso normal.
s_ok:
    .word 0                       // Status do caso normal.
q_div0:
    .quad 0                       // Resultado do caso DIV0.
s_div0:
    .word 0                       // Status do caso DIV0.
