// ENUNCIADO COMPLETO (TEXTO INTEGRAL DO HTML, SEM TAGS)
// Exercício 2 Classificador de caracteres para sanitização de telemetria (isAlnum)
// 
// Tarefa:
// 
// Em telemetria embarcada, strings de identificação (IDs) podem conter caracteres inválidos e causar rejeição por sistemas downstream. Antes de enviar dados, o firmware precisa validar se um caractere ASCII é alfanumérico (0–9, A–Z, a–z). Você deve implementar uma função de biblioteca que recebe um byte (em registrador) e retorna um boolean estritamente normalizado (0 ou 1). Essa função será chamada em alta frequência e deve respeitar o PCS do AArch64. A implementação deve ser determinística e adequada para integração com rotinas maiores, sem corromper contexto. A correção será validada por múltiplos casos no GDB, incluindo limites de intervalos ASCII.
// 
// Requisitos Técnicos e Saídas Esperadas:
// 
// - Modularidade: isAlnum em lib.S; main.S chama a função com pelo menos 4 caracteres de teste.
// 
// - Tipo de dados: ASCII byte em W0 (usar apenas os 8 bits menos significativos).
// 
// - Interface:
// 
// - entrada: W0 = caractere
// 
// - saída: W0 = 1 se alfanumérico, senão 0.
// 
// - Pilha / ABI: preservar X30 e quaisquer X19–X28 usados. Não deixar lixo na pilha.
// 
// - Validação: em GDB, para 'A' retorna 1; para '9' retorna 1; para '_' retorna 0; para 0x7F retorna 0.
//
// Exercicio 2 - Chamador de isAlnum
//
// Como funciona:
// 1) Envia 4 caracteres de teste para a funcao isAlnum.
// 2) Guarda cada retorno em um vetor de resultados.
// 3) Fecha o programa com syscall exit.

.text
.global _start
.extern isAlnum

_start:
    adr x1, test_chars            // X1 aponta para vetor de caracteres de teste.
    adr x2, results               // X2 aponta para vetor onde sera salvo 0/1.
    mov x3, #4                    // Contador de 4 testes.

loop_tests:
    ldrb w0, [x1], #1             // Le um caractere e avanca ponteiro.
    bl isAlnum                    // Chama classificador (retorno em W0).
    strb w0, [x2], #1             // Salva resultado (0 ou 1) e avanca ponteiro.
    subs x3, x3, #1               // Decrementa contador.
    b.ne loop_tests               // Continua ate testar os 4 caracteres.

    mov x0, #0                    // Codigo de saida 0.
    mov x8, #93                   // Syscall exit.
    svc #0                        // Encerra.

.data
test_chars:
    .byte 'A', '9', '_', 0x7F     // Casos pedidos no enunciado.
results:
    .space 4                      // Vetor para guardar 4 retornos.
