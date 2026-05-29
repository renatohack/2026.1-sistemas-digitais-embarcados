`timescale 1ns/1ps

module tb_pll_54mhz;
    reg clk_27;
    reg reset;
    wire clk_proc;
    wire pll_locked;

    integer clk27_edges;
    integer clkproc_edges;

    pll_54mhz dut (
        .clkin(clk_27),
        .reset(reset),
        .clkout(clk_proc),
        .lock(pll_locked)
    );

    initial begin
        clk_27 = 1'b0;
        forever #18.5 clk_27 = ~clk_27;
    end

    always @(posedge clk_27)
        if (pll_locked)
            clk27_edges = clk27_edges + 1;

    always @(posedge clk_proc)
        if (pll_locked)
            clkproc_edges = clkproc_edges + 1;

    initial begin
        $dumpfile("build/waves/tb_pll_54mhz.vcd");
        $dumpvars(0, tb_pll_54mhz);

        clk27_edges = 0;
        clkproc_edges = 0;
        reset = 1'b1;
        #60;
        reset = 1'b0;

        wait (pll_locked);
        #2000;

        if (clkproc_edges < (clk27_edges * 2 - 2)) begin
            $display("FAIL: pll clock ratio too low clk27=%0d clkproc=%0d", clk27_edges, clkproc_edges);
            $finish_and_return(1);
        end

        $display("PASS: pll simulation model locked and generated derived clock");
        $finish;
    end
endmodule
