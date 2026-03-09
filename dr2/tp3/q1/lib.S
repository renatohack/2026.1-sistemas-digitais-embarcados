// Exercicio 1 - Rotina toLowerCase
//
// Como funciona:
// 1) Recebe em X0 o endereco de uma string ASCII terminada em 0x00.
// 2) Percorre byte a byte ate encontrar 0x00.
// 3) Se o byte estiver entre 'A' e 'Z', soma 32 para virar minusculo.
// 4) Mantem todos os outros bytes sem alteracao.
// 5) Retorna em X0 o mesmo ponteiro recebido.

.text
.global toLowerCase

toLowerCase:
    stp x29, x30, [sp, -16]!      // Cria frame e salva LR para respeitar ABI.
    mov x29, sp                   // Define frame pointer do frame atual.
    mov x1, x0                    // Guarda o ponteiro original para retornar no final.

loop_tolower:
    ldrb w2, [x0]                 // Le o byte atual da string.
    cbz w2, end_tolower           // Se for 0x00, chegou ao fim da string.

    cmp w2, #'A'                  // Compara com limite inferior de letra maiuscula.
    blt next_char                 // Se for menor que 'A', nao converte.
    cmp w2, #'Z'                  // Compara com limite superior de letra maiuscula.
    bgt next_char                 // Se for maior que 'Z', nao converte.

    add w2, w2, #32               // Converte 'A'..'Z' para 'a'..'z'.
    strb w2, [x0]                 // Escreve o byte convertido no mesmo lugar.

next_char:
    add x0, x0, #1                // Avanca para o proximo byte da string.
    b loop_tolower                // Continua o loop.

end_tolower:
    mov x0, x1                    // Retorna o mesmo ponteiro de entrada.
    ldp x29, x30, [sp], #16       // Restaura frame pointer e LR.
    ret                           // Volta para o chamador.
