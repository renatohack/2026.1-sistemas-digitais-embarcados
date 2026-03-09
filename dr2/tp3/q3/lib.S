// Exercicio 3 - Funcoes de biblioteca com chamadas aninhadas
//
// Como funciona:
// - toLowerCase: normaliza uma string ASCII para lowercase.
// - hashStub: retorna uma constante fixa de 64 bits.
// - normalizeThenHashStub:
//   1) recebe ponteiro da string em X0,
//   2) chama toLowerCase,
//   3) chama hashStub,
//   4) retorna o hash em X0.
//
// O foco aqui e preservar contexto durante BL, incluindo X30 e registradores
// callee-saved usados na funcao intermediaria.

.text
.global toLowerCase
.global hashStub
.global normalizeThenHashStub

toLowerCase:
    stp x29, x30, [sp, -16]!      // Cria frame e salva LR.
    mov x29, sp                   // Define frame pointer.
    mov x1, x0                    // Guarda ponteiro original para retorno.

loop_tolower_q3:
    ldrb w2, [x0]                 // Le byte atual.
    cbz w2, end_tolower_q3        // Encerra no terminador 0x00.

    cmp w2, #'A'                  // Testa limite inferior de maiusculas.
    blt next_char_q3              // Se menor, nao converte.
    cmp w2, #'Z'                  // Testa limite superior de maiusculas.
    bgt next_char_q3              // Se maior, nao converte.

    add w2, w2, #32               // Converte para minuscula.
    strb w2, [x0]                 // Grava o byte convertido.

next_char_q3:
    add x0, x0, #1                // Avanca para o proximo byte.
    b loop_tolower_q3             // Continua o loop.

end_tolower_q3:
    mov x0, x1                    // Retorna ponteiro original.
    ldp x29, x30, [sp], #16       // Restaura frame e LR.
    ret                           // Volta para o chamador.

hashStub:
    stp x29, x30, [sp, -16]!      // Cria frame e salva LR.
    mov x29, sp                   // Define frame pointer.

    movz x0, #0xCDEF              // Monta parte baixa da constante.
    movk x0, #0x89AB, lsl #16     // Monta bits 31..16.
    movk x0, #0x4567, lsl #32     // Monta bits 47..32.
    movk x0, #0x0123, lsl #48     // Monta bits 63..48.

    ldp x29, x30, [sp], #16       // Restaura frame e LR.
    ret                           // Retorna constante em X0.

normalizeThenHashStub:
    stp x29, x30, [sp, -16]!      // Cria frame e salva LR.
    mov x29, sp                   // Define frame pointer.
    stp x19, x20, [sp, -16]!      // Salva callee-saved usados.

    mov x19, x0                   // Guarda ponteiro original da string.

    bl toLowerCase                // Normaliza a string para lowercase.

    mov x0, x19                   // Recoloca ponteiro para o hashStub.
    bl hashStub                   // Retorna hash fixo em X0.

    ldp x19, x20, [sp], #16       // Restaura callee-saved.
    ldp x29, x30, [sp], #16       // Restaura frame e LR.
    ret                           // Volta ao chamador com hash em X0.
