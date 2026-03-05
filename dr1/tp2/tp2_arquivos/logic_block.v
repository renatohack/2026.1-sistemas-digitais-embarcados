module Logic_Block (
    input  wire A,
    input  wire B,
    input  wire C,
    output wire F
);

    assign F = (A & B) | (~C);

endmodule
