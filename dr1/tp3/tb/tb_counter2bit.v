`timescale 1ns/1ps

module tb_counter2bit;
    reg clk;
    reg reset;
    wire [1:0] Q;

    Counter2bit dut (
        .clk(clk),
        .reset(reset),
        .Q(Q)
    );

    always #5 clk = ~clk;

    initial begin
        $display("\n==== TB Counter2bit ====");
        $display("tempo clk reset | Q1Q0");
        $monitor("%4t   %0d    %0d   | %0d%0d", $time, clk, reset, Q[1], Q[0]);

        clk = 1'b0;
        reset = 1'b1;
        #12;

        reset = 1'b0;
        #80;

        reset = 1'b1;
        #10;

        reset = 1'b0;
        #40;

        $display("==== Fim TB Counter2bit ====\n");
        $finish;
    end
endmodule
