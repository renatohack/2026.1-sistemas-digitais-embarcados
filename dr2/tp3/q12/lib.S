// Exercicio 12 - Funcoes de energia cinetica em float e double
//
// Como funciona:
// - ke_f32:
//   Entrada S0=m, S1=v
//   Saida   S0=0.5*m*v^2
// - ke_f64:
//   Entrada D0=m, D1=v
//   Saida   D0=0.5*m*v^2
//
// As duas funcoes sao modulares para comparacao de precisao no chamador.

.text
.global ke_f32
.global ke_f64

ke_f32:
    stp x29, x30, [sp, -16]!      // Cria frame e salva LR.
    mov x29, sp                   // Define frame pointer.

    adr x9, const_half_f32        // Endereco da constante 0.5 em float.
    ldr s2, [x9]                  // S2 = 0.5.

    fmul s1, s1, s1               // S1 = v^2.
    fmul s0, s0, s1               // S0 = m * v^2.
    fmul s0, s0, s2               // S0 = 0.5 * m * v^2.

    ldp x29, x30, [sp], #16       // Restaura frame e LR.
    ret                           // Retorna energia em S0.

ke_f64:
    stp x29, x30, [sp, -16]!      // Cria frame e salva LR.
    mov x29, sp                   // Define frame pointer.

    adr x9, const_half_f64        // Endereco da constante 0.5 em double.
    ldr d2, [x9]                  // D2 = 0.5.

    fmul d1, d1, d1               // D1 = v^2.
    fmul d0, d0, d1               // D0 = m * v^2.
    fmul d0, d0, d2               // D0 = 0.5 * m * v^2.

    ldp x29, x30, [sp], #16       // Restaura frame e LR.
    ret                           // Retorna energia em D0.

.data
const_half_f32:
    .float 0.5                    // Constante 0.5 float.
const_half_f64:
    .double 0.5                   // Constante 0.5 double.
