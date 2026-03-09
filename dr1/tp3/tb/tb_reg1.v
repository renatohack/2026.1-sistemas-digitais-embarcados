`timescale 1ns/1ps

module tb_reg1;
    reg D;
    reg clk;
    reg reset;
    wire Q;

    Reg1 dut (
        .D(D),
        .clk(clk),
        .reset(reset),
        .Q(Q)
    );

    always #5 clk = ~clk;

    initial begin
        $display("\n==== TB Reg1 ====");
        $display("tempo clk reset D | Q");
        $monitor("%4t   %0d    %0d    %0d | %0d", $time, clk, reset, D, Q);

        clk = 1'b0;
        D = 1'b0;
        reset = 1'b1;
        #12;

        reset = 1'b0; D = 1'b1; #10;
        D = 1'b0; #10;
        D = 1'b1; #10;

        reset = 1'b1; #10;
        reset = 1'b0; D = 1'b0; #10;

        $display("==== Fim TB Reg1 ====\n");
        $finish;
    end
endmodule
