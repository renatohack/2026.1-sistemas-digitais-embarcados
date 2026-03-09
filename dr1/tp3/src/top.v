`timescale 1ns/1ps

// TP3 - Etapa 7
// Top-level para validar fisicamente o contador na Tang Nano 9K.
module top (
    input  wire clk,
    input  wire reset,
    output wire led0,
    output wire led1
);
    wire [1:0] count;

    Counter2bit u_counter (
        .clk(clk),
        .reset(reset),
        .Q(count)
    );

    assign led0 = count[0];
    assign led1 = count[1];

endmodule
