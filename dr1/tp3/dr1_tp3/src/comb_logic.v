`timescale 1ns/1ps

// TP3 - Etapa 4
// Modulo combinacional para a expressao minimizada de F(A,B,C).
module Comb_Logic (
    input  wire A,
    input  wire B,
    input  wire C,
    output wire F
);
    // Para F(A,B,C) = Sm(1,3,5,7), a forma minimizada e F = C.
    assign F = C;

endmodule
