`timescale 1ns/1ps

// TP3 - Etapa 6
// Flip-flop D com reset sincrono ativo em nivel alto.
module Reg1 (
    input  wire D,
    input  wire clk,
    input  wire reset,
    output reg  Q
);
    always @(posedge clk) begin
        if (reset)
            Q <= 1'b0;
        else
            Q <= D;
    end

endmodule
