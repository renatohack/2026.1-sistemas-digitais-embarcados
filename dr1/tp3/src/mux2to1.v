`timescale 1ns/1ps

// TP3 - Etapa 5
// Multiplexador 2:1 combinacional.
module Mux2to1 (
    input  wire D0,
    input  wire D1,
    input  wire S,
    output wire Y
);
    assign Y = S ? D1 : D0;

endmodule
