// ENUNCIADO COMPLETO (TEXTO INTEGRAL DO HTML, SEM TAGS)
// Exercício 11 Borda inteira: overflow detectável em MSUB/MADD
// 
// Tarefa:
// 
// Em rotinas de física computacional embarcada, produtos e acumulações podem exceder o intervalo representável e produzir overflow silencioso em inteiros. Embora o ARM64 não levante exceção por overflow inteiro padrão, você deve projetar um teste que evidencie o comportamento e permita validação por inspeção do resultado e/ou flags (quando aplicável). O objetivo é implementar uma função que compute y = ab + c (e a variante y = c - ab) usando instruções dedicadas, e construir casos de borda que mostrem saturação modular (wrap-around) em 64 bits. A correção é por resultado esperado (mod 2^64) e disciplina ABI.
// 
// Requisitos Técnicos e Saídas Esperadas:
// 
// - Tipo de dados: inteiros 64-bit.
// 
// - Interface: entrada X0=a, X1=b, X2=c, X3=mode (0=MADD, 1=MSUB); saída X0=y.
// 
// - Implementação: usar MADD quando mode=0 e MSUB quando mode=1.
// 
// - Borda: fornecer no chamador um caso que provoque wrap-around (ex.: a=0x4000000000000000, b=4, c=0).
// 
// - Pilha / ABI: preservar X30 e callee-saved usados.
// 
// - Validação: em GDB, confirmar y exatamente conforme aritmética modular de 64 bits para os casos fornecidos.
//
// Exercicio 11 - MADD/MSUB com caso de wrap-around em 64 bits
//
// Como funciona:
// 1) Entrada: X0=a, X1=b, X2=c, X3=mode.
// 2) mode=0 -> y = a*b + c usando MADD.
// 3) mode=1 -> y = c - a*b usando MSUB.
// 4) Retorna y em X0 (aritmetica modular de 64 bits).

.text
.global _start
.global maddMsub64

_start:
    movz x0, #0x4000, lsl #48     // a = 0x4000000000000000 (caso de borda).
    mov x1, #4                    // b = 4.
    mov x2, #0                    // c = 0.
    mov x3, #0                    // mode 0 = MADD.
    bl maddMsub64                 // Calcula y = a*b + c.
    adr x9, y_wrap_madd           // Endereco para salvar resultado MADD.
    str x0, [x9]                  // Salva resultado com wrap-around.

    movz x0, #0x4000, lsl #48     // a = 0x4000000000000000 novamente.
    mov x1, #4                    // b = 4.
    mov x2, #0                    // c = 0.
    mov x3, #1                    // mode 1 = MSUB.
    bl maddMsub64                 // Calcula y = c - a*b.
    adr x9, y_wrap_msub           // Endereco para salvar resultado MSUB.
    str x0, [x9]                  // Salva resultado com wrap-around.

    mov x0, #0                    // Codigo de saida 0.
    mov x8, #93                   // Syscall exit.
    svc #0                        // Encerra.

maddMsub64:
    stp x29, x30, [sp, -16]!      // Cria frame e salva LR.
    mov x29, sp                   // Define frame pointer.

    cmp x3, #1                    // Verifica se o modo e MSUB.
    beq do_msub                   // Se mode==1, executa MSUB.

    madd x0, x0, x1, x2           // mode==0: y = a*b + c.
    b end_madd_msub               // Vai para epilogo.

do_msub:
    msub x0, x0, x1, x2           // mode==1: y = c - a*b.

end_madd_msub:
    ldp x29, x30, [sp], #16       // Restaura frame e LR.
    ret                           // Retorna y em X0.

.data
y_wrap_madd:
    .quad 0                       // Resultado do caso de borda com MADD.
y_wrap_msub:
    .quad 0                       // Resultado do caso de borda com MSUB.
