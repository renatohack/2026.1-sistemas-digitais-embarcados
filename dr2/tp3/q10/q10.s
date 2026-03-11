// ENUNCIADO COMPLETO (TEXTO INTEGRAL DO HTML, SEM TAGS)
// Exercício 10 Borda FP: divisão por zero e sinalização (NaN/Inf handling)
// 
// Tarefa:
// 
// Em sistemas críticos, operações de ponto flutuante podem produzir infinito ou NaN, e isso precisa ser tratado explicitamente para evitar propagação silenciosa de erros. Você deve implementar uma função safeInv que calcula 1.0/x em double e classifica o resultado. Quando x=0, o retorno IEEE-754 será infinito (com sinal); quando x for NaN, o retorno permanece NaN. A função deve retornar o valor em D0 e um código de status inteiro para o chamador decidir se continua o pipeline. O foco é lidar com bordas sem crash e com resultado auditável.
// 
// Requisitos Técnicos e Saídas Esperadas:
// 
// - Tipo de dados: double para cálculo, int32 para status.
// 
// - Interface: entrada D0=x; saída D0=1.0/x, W0=status (0=OK, 1=DIV0, 2=NAN).
// 
// - Borda: x=0.0 → status DIV0; x=NaN → status NAN.
// 
// - Pilha / ABI: preservar X30 e callee-saved usados; stack alinhado.
// 
// - Validação: em GDB, safeInv(0.0) deve retornar +Inf ou -Inf em D0 (conforme sinal) e status 1; safeInv(NaN) retorna NaN e status 2.
//
// Exercicio 10 - safeInv com classificacao de borda FP
//
// Como funciona:
// 1) Entrada D0 = x.
// 2) Se x for NaN: retorna status W0=2 e mantem D0 (NaN).
// 3) Se x for 0.0: calcula 1.0/x (gera +Inf ou -Inf), retorna W0=1.
// 4) Caso normal: calcula 1.0/x e retorna W0=0.
//
// Saidas:
// - D0 = 1.0/x (ou NaN preservado)
// - W0 = status (0=OK, 1=DIV0, 2=NAN)

.text
.global _start
.global safeInv

_start:
    adr x9, x_zero                // Endereco do teste x=0.0.
    ldr d0, [x9]                  // D0 = 0.0.
    bl safeInv                    // Esperado: D0=Inf e W0=1.
    adr x9, status_div0           // Endereco para salvar status DIV0.
    str w0, [x9]                  // Salva status do caso zero.
    adr x9, inv_div0              // Endereco para salvar valor retornado.
    str d0, [x9]                  // Salva +Inf/-Inf.

    adr x9, x_nan_bits            // Endereco de um NaN em formato binario.
    ldr d0, [x9]                  // D0 = NaN.
    bl safeInv                    // Esperado: D0=NaN e W0=2.
    adr x9, status_nan            // Endereco para salvar status NAN.
    str w0, [x9]                  // Salva status do caso NaN.
    adr x9, inv_nan               // Endereco para salvar retorno NaN.
    str d0, [x9]                  // Salva NaN retornado.

after_results_saved:
    mov x0, #0                    // Codigo de saida 0.
    mov x8, #93                   // Syscall exit.
    svc #0                        // Encerra.

safeInv:
    stp x29, x30, [sp, -16]!      // Cria frame e salva LR.
    mov x29, sp                   // Define frame pointer.

    fcmp d0, d0                   // Compara x com ele mesmo para detectar NaN.
    b.vs case_nan                 // Se unordered, x e NaN.

    adr x9, const_0_0             // Endereco da constante 0.0.
    ldr d1, [x9]                  // D1 = 0.0.
    fcmp d0, d1                   // Compara x com zero.
    b.eq case_div0                // Se x==0.0, sinaliza DIV0.

    adr x9, const_1_0             // Endereco da constante 1.0.
    ldr d1, [x9]                  // D1 = 1.0.
    fdiv d0, d1, d0               // D0 = 1.0 / x (caso normal).
    mov w0, #0                    // Status OK.
    b end_safeinv                 // Vai para epilogo.

case_div0:
    adr x9, const_1_0             // Endereco da constante 1.0.
    ldr d1, [x9]                  // D1 = 1.0.
    fdiv d0, d1, d0               // D0 = 1.0 / 0.0 -> +Inf ou -Inf.
    mov w0, #1                    // Status DIV0.
    b end_safeinv                 // Vai para epilogo.

case_nan:
    mov w0, #2                    // Status NAN.

end_safeinv:
    ldp x29, x30, [sp], #16       // Restaura frame e LR.
    ret                           // Retorna valor em D0 e status em W0.

.data
const_0_0:
    .double 0.0                   // Constante zero.
const_1_0:
    .double 1.0                   // Constante um.
x_zero:
    .double 0.0                   // Caso de teste x=0.0.
x_nan_bits:
    .quad 0x7ff8000000000000      // Quiet NaN em IEEE-754 double.
status_div0:
    .word 0                       // Status do teste com zero.
status_nan:
    .word 0                       // Status do teste com NaN.
inv_div0:
    .double 0.0                   // Valor retornado para x=0.0.
inv_nan:
    .double 0.0                   // Valor retornado para x=NaN.
