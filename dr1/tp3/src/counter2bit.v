`timescale 1ns/1ps

// TP3 - Etapa 6
// Contador binario de 2 bits usando dois flip-flops Reg1.
module Counter2bit (
    input  wire       clk,
    input  wire       reset,
    output wire [1:0] Q
);
    wire d0;
    wire d1;

    // Proximo estado para contador modulo 4:
    // 00 -> 01 -> 10 -> 11 -> 00
    assign d0 = ~Q[0];
    assign d1 = Q[1] ^ Q[0];

    Reg1 ff0 (
        .D(d0),
        .clk(clk),
        .reset(reset),
        .Q(Q[0])
    );

    Reg1 ff1 (
        .D(d1),
        .clk(clk),
        .reset(reset),
        .Q(Q[1])
    );

endmodule
