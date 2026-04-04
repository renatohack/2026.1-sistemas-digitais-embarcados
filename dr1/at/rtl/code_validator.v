`timescale 1ns / 1ps

module code_validator (
    input  wire [3:0] code_in,
    output wire       code_valid
);
    // Codigo valido: 1011
    assign code_valid = code_in[3] & ~code_in[2] & code_in[1] & code_in[0];
endmodule
