`timescale 1ns/1ps

module tb_bram;
    reg clk;
    reg we;
    reg [3:0] addr;
    reg signed [15:0] din;
    wire signed [15:0] dout;

    sample_bram dut (
        .clk(clk),
        .we(we),
        .addr(addr),
        .din(din),
        .dout(dout)
    );

    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    task write_sample;
        input [3:0] wr_addr;
        input signed [15:0] wr_data;
        begin
            @(negedge clk);
            addr = wr_addr;
            din = wr_data;
            we = 1'b1;
            @(posedge clk);
            @(negedge clk);
            we = 1'b0;
            @(posedge clk);
        end
    endtask

    task read_and_check;
        input [3:0] rd_addr;
        input signed [15:0] expected;
        begin
            @(negedge clk);
            addr = rd_addr;
            we = 1'b0;
            @(posedge clk);
            @(negedge clk);
            if (dout !== expected) begin
                $display("FAIL: BRAM addr %0d expected %0d got %0d", rd_addr, expected, dout);
                $finish_and_return(1);
            end
        end
    endtask

    integer i;

    initial begin
        $dumpfile("build/waves/tb_bram.vcd");
        $dumpvars(0, tb_bram);

        we = 1'b0;
        addr = 4'd0;
        din = 16'sd0;
        repeat (2) @(posedge clk);

        for (i = 0; i < 16; i = i + 1)
            write_sample(i[3:0], $signed(i * 3 - 20));

        for (i = 0; i < 16; i = i + 1)
            read_and_check(i[3:0], $signed(i * 3 - 20));

        $display("PASS: synchronous BRAM write/read");
        $finish;
    end
endmodule
