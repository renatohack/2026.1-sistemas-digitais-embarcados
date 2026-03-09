// ENUNCIADO COMPLETO (TEXTO INTEGRAL DO HTML, SEM TAGS)
// Exercício 1 Rotina de normalização ASCII para logs (toLowerCase)
// 
// Tarefa:
// 
// Em um sistema embarcado de monitoramento, mensagens de log chegam por UART com mistura de maiúsculas e minúsculas. Para reduzir entropia na indexação e permitir filtros determinísticos em pipelines de diagnóstico, o firmware precisa normalizar essas mensagens para lowercase antes de encaminhá-las ao subsistema de armazenamento. Você deve implementar uma rotina modular em Assembly AArch64 que opere sobre um buffer ASCII terminado em zero, convertendo apenas letras 'A'..'Z' para 'a'..'z' e preservando todos os demais bytes (pontuação, dígitos e controle). O chamador deverá poder reutilizar essa rotina em múltiplos pontos do firmware, exigindo conformidade com o padrão de chamada e isolamento em arquivo de biblioteca. A correção será avaliada por inspeção do buffer em memória e preservação do contexto do chamador.
// 
// Requisitos Técnicos e Saídas Esperadas:
// 
// - Modularidade: implementar toLowerCase em lib.S e um chamador em main.S que prepara o buffer e chama a função.
// 
// - Tipo de dados: string ASCII (bytes) terminada em 0x00.
// 
// - Interface (entrada/saída):
// 
// - entrada: X0 = endereço do buffer
// 
// - saída: X0 = endereço do mesmo buffer (convenção de “retorna ponteiro”).
// 
// - Pilha / ABI: função deve preservar todos os registradores callee-saved que utilizar (X19–X28) e preservar X30 via prólogo/epílogo.
// 
// - Validação: no GDB, após retorno, o conteúdo do buffer deve estar em lowercase. Exemplo de teste: ""InfNET-DR3!\n\0"" deve virar ""infnet-dr3!\n\0"".
//
// Exercicio 1 - Chamador da rotina toLowerCase
//
// Como funciona:
// 1) Prepara um buffer ASCII de teste na memoria.
// 2) Passa o endereco do buffer para toLowerCase em X0.
// 3) Apos retorno, o buffer fica normalizado em lowercase.
// 4) Programa encerra com syscall exit.

.text
.global _start
.extern toLowerCase

_start:
    adr x0, buffer                // Coloca em X0 o endereco da string de teste.
    bl toLowerCase                // Chama a rotina de normalizacao.

    mov x0, #0                    // Define codigo de saida 0.
    mov x8, #93                   // Numero da syscall exit no Linux AArch64.
    svc #0                        // Executa a syscall para encerrar o programa.

.data
buffer:
    .asciz "InfNET-DR3!\n"        // String que deve virar "infnet-dr3!\n".
