// ENUNCIADO COMPLETO (TEXTO INTEGRAL DO HTML, SEM TAGS)
// Exercício 5 Dot Product inteiro otimizado com MADD (Q15 audio mixing)
// 
// Tarefa:
// 
// Em processamento de áudio embarcado, operações do tipo dot product aparecem em filtros FIR e mixers. Para eficiência, utiliza-se multiply-accumulate com instruções dedicadas. Você deve implementar uma função que calcule o dot product entre dois vetores de inteiros 32-bit (valores Q15 representados em 32 bits) com comprimento N, retornando um acumulador de 64 bits. O foco é usar uma instrução de multiply-add para reduzir contagem de instruções e preservar o contexto do chamador. A correção será verificada por casos pequenos e previsíveis e por inspeção do acumulador final.
// 
// Requisitos Técnicos e Saídas Esperadas:
// 
// - Tipo de dados: vetores de int32 (em memória), acumulador int64.
// 
// - Interface:
// 
// - entrada: X0=ptrA, X1=ptrB, X2=N
// 
// - saída: X0=acc64.
// 
// - Cálculo: acc = Σ (A[i] * B[i]) para i=0..N-1.
// 
// - Otimização obrigatória: usar MADD (ou equivalente) no caminho crítico do acumulador.
// 
// - Pilha / ABI: preservar X30 e quaisquer X19–X28 usados para ponteiros/contadores.
// 
// - Validação: com A=[1,2,3,4], B=[10,20,30,40], N=4, retorno deve ser 300 em X0.
//
// Exercicio 5 - Dot Product inteiro com MADD
//
// Como funciona:
// 1) Recebe X0=ptrA, X1=ptrB, X2=N.
// 2) Percorre os N elementos int32 dos dois vetores.
// 3) Em cada passo faz acc = acc + A[i] * B[i] usando MADD.
// 4) Retorna acc (int64) em X0.

.text
.global _start
.global dotProduct

_start:
    adr x0, vecA                  // X0 aponta para vetor A.
    adr x1, vecB                  // X1 aponta para vetor B.
    mov x2, #4                    // N=4 conforme caso de validacao.
    bl dotProduct                 // Calcula o dot product.

    adr x3, result_acc            // X3 aponta para area de resultado.
    str x0, [x3]                  // Salva acumulador final em memoria.

    mov x0, #0                    // Codigo de saida 0.
    mov x8, #93                   // Syscall exit.
    svc #0                        // Encerra.

dotProduct:
    stp x29, x30, [sp, -16]!      // Cria frame e salva LR.
    mov x29, sp                   // Define frame pointer.

    mov x5, #0                    // Inicializa acc=0.
    cbz x2, done_dot              // Se N=0, retorna 0 imediatamente.

loop_dot:
    ldrsw x3, [x0], #4            // Le A[i] com extensao de sinal e avanca ptrA.
    ldrsw x4, [x1], #4            // Le B[i] com extensao de sinal e avanca ptrB.
    madd x5, x3, x4, x5           // acc = (A[i]*B[i]) + acc.
    subs x2, x2, #1               // Decrementa contador N.
    b.ne loop_dot                 // Continua enquanto N != 0.

done_dot:
    mov x0, x5                    // Retorna acc em X0.
    ldp x29, x30, [sp], #16       // Restaura frame e LR.
    ret                           // Volta ao chamador.

.data
vecA:
    .word 1, 2, 3, 4              // Vetor A de teste.
vecB:
    .word 10, 20, 30, 40          // Vetor B de teste.
result_acc:
    .quad 0                       // Guarda o resultado final.
