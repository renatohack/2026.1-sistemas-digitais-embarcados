// Exercicio 2 - Funcao isAlnum
//
// Como funciona:
// 1) Recebe em W0 um caractere ASCII (usa somente os 8 bits baixos).
// 2) Verifica se pertence a um destes intervalos:
//    '0'..'9', 'A'..'Z', 'a'..'z'.
// 3) Retorna W0=1 se for alfanumerico, senao retorna W0=0.

.text
.global isAlnum

isAlnum:
    stp x29, x30, [sp, -16]!      // Cria frame e salva LR.
    mov x29, sp                   // Define frame pointer.

    uxtb w0, w0                   // Garante uso apenas do byte menos significativo.

    cmp w0, #'0'                  // Inicio do intervalo de digitos.
    blt check_upper               // Se menor, nao e digito.
    cmp w0, #'9'                  // Fim do intervalo de digitos.
    ble is_true                   // Se estiver no intervalo, retorna 1.

check_upper:
    cmp w0, #'A'                  // Inicio do intervalo de maiusculas.
    blt check_lower               // Se menor, testa minusculas.
    cmp w0, #'Z'                  // Fim do intervalo de maiusculas.
    ble is_true                   // Se estiver no intervalo, retorna 1.

check_lower:
    cmp w0, #'a'                  // Inicio do intervalo de minusculas.
    blt is_false                  // Se menor, nao e alfanumerico.
    cmp w0, #'z'                  // Fim do intervalo de minusculas.
    ble is_true                   // Se estiver no intervalo, retorna 1.

is_false:
    mov w0, #0                    // Retorno falso.
    b end_isalnum                 // Salta para epilogo.

is_true:
    mov w0, #1                    // Retorno verdadeiro.

end_isalnum:
    ldp x29, x30, [sp], #16       // Restaura frame pointer e LR.
    ret                           // Volta ao chamador.
