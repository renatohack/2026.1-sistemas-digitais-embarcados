// ENUNCIADO COMPLETO (TEXTO INTEGRAL DO HTML, SEM TAGS)
// Exercício 3 Função com chamadas aninhadas e preservação de contexto (normalizeThenHashStub)
// 
// Tarefa:
// 
// Em um pipeline de autenticação embarcada, uma etapa comum é normalizar um identificador e em seguida calcular um valor derivado (hash, CRC ou checksum). Mesmo que o hash completo seja implementado depois, o firmware já precisa validar a estrutura modular com chamadas aninhadas e preservação de contexto. Você deve escrever uma função que chama outra função de biblioteca, preservando corretamente registradores não voláteis e o link register. O objetivo é demonstrar domínio de prólogo/epílogo e do fato de que chamadas via BL sobrescrevem X30. A validação foca na integridade do contexto e no encadeamento correto de chamadas.
// 
// Requisitos Técnicos e Saídas Esperadas:
// 
// - Modularidade: toLowerCase e hashStub em lib.S; main.S chama normalizeThenHashStub.
// 
// - Tipo de dados: string ASCII terminada em zero; hash de 64 bits.
// 
// - Interface:
// 
// - normalizeThenHashStub: entrada X0=ptr; saída X0=hash64
// 
// - hashStub: entrada X0=ptr; saída X0=0x0123456789ABCDEF (constante fixa).
// 
// - Pilha / ABI: normalizeThenHashStub deve salvar/restaurar X30 e qualquer X19–X28 usado, garantindo que o chamador não seja corrompido.
// 
// - Validação: em GDB, após a chamada: (i) string está em lowercase; (ii) retorno em X0 é 0x0123456789ABCDEF; (iii) registradores callee-saved usados retornam ao valor original.
//
// Exercicio 3 - Chamador de normalizeThenHashStub
//
// Como funciona:
// 1) Prepara string de teste no buffer.
// 2) Define um valor em X19 para checar preservacao de contexto.
// 3) Chama normalizeThenHashStub.
// 4) Salva hash e o valor final de X19 na memoria para inspecao no GDB.

.text
.global _start
.extern normalizeThenHashStub

_start:
    mov x19, #0x55                // Coloca valor conhecido em callee-saved do chamador.

    adr x0, buffer                // X0 recebe endereco da string de teste.
    bl normalizeThenHashStub      // Chama funcao com chamadas aninhadas.

    adr x1, hash_result           // X1 aponta para onde guardar o hash.
    str x0, [x1]                  // Salva hash retornado em memoria.

    adr x1, caller_x19_after      // X1 aponta para area de debug do X19.
    str x19, [x1]                 // Salva X19 apos retorno para validar preservacao.

after_results_saved:
    mov x0, #0                    // Codigo de saida 0.
    mov x8, #93                   // Syscall exit.
    svc #0                        // Encerra programa.

.data
buffer:
    .asciz "AbC-DeF123!"          // Deve virar "abc-def123!".
hash_result:
    .quad 0                       // Recebe 0x0123456789ABCDEF.
caller_x19_after:
    .quad 0                       // Deve manter 0x55.
