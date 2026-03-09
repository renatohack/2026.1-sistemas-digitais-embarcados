`timescale 1ns/1ps

module tb_comb_logic;
    reg A;
    reg B;
    reg C;
    wire F;

    integer i;

    Comb_Logic dut (
        .A(A),
        .B(B),
        .C(C),
        .F(F)
    );

    initial begin
        $display("\n==== TB Comb_Logic ====");
        $display("A B C | F");
        $display("-------------");

        for (i = 0; i < 8; i = i + 1) begin
            {A, B, C} = i[2:0];
            #10;
            $display("%0d %0d %0d | %0d", A, B, C, F);
        end

        $display("==== Fim TB Comb_Logic ====\n");
        $finish;
    end
endmodule
