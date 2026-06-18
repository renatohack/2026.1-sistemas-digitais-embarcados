`timescale 1ns/1ps

module tb_extreme_metrics;
    reg clk;
    reg rst_n;
    reg clear;
    reg sample_valid;
    reg finalize;
    reg signed [15:0] sample_in;

    wire signed [31:0] sum_acc;
    wire [39:0] sumsq_acc;
    wire signed [31:0] sum_out;
    wire signed [31:0] mean_out;
    wire [31:0] rms2_out;
    wire [4:0] sample_count;
    wire done;
    wire overflow;

    arithmetic_datapath dut (
        .clk(clk),
        .rst_n(rst_n),
        .clear(clear),
        .sample_valid(sample_valid),
        .finalize(finalize),
        .sample_in(sample_in),
        .sum_acc(sum_acc),
        .sumsq_acc(sumsq_acc),
        .sum_out(sum_out),
        .mean_out(mean_out),
        .rms2_out(rms2_out),
        .sample_count(sample_count),
        .done(done),
        .overflow(overflow)
    );

    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    task reset_datapath;
        begin
            @(negedge clk);
            clear = 1'b1;
            sample_valid = 1'b0;
            finalize = 1'b0;
            sample_in = 16'sd0;
            @(posedge clk);
            @(negedge clk);
            clear = 1'b0;
            @(posedge clk);
        end
    endtask

    task feed_sample;
        input signed [15:0] value;
        begin
            @(negedge clk);
            sample_in = value;
            sample_valid = 1'b1;
            @(posedge clk);
            @(negedge clk);
            sample_valid = 1'b0;
            @(posedge clk);
        end
    endtask

    task finish_and_check;
        input signed [31:0] expected_sum;
        input signed [31:0] expected_mean;
        input [31:0] expected_rms2;
        begin
            @(negedge clk);
            finalize = 1'b1;
            @(posedge clk);
            @(negedge clk);
            finalize = 1'b0;
            @(posedge clk);

            if (sum_out !== expected_sum) begin
                $display("FAIL: expected sum %0d, got %0d", expected_sum, sum_out);
                $finish_and_return(1);
            end

            if (mean_out !== expected_mean) begin
                $display("FAIL: expected mean %0d, got %0d", expected_mean, mean_out);
                $finish_and_return(1);
            end

            if (rms2_out !== expected_rms2) begin
                $display("FAIL: expected rms2 %0d, got %0d", expected_rms2, rms2_out);
                $finish_and_return(1);
            end

            if (overflow !== 1'b0) begin
                $display("FAIL: unexpected overflow");
                $finish_and_return(1);
            end
        end
    endtask

    integer i;

    initial begin
        $dumpfile("build/waves/tb_extreme_metrics.vcd");
        $dumpvars(0, tb_extreme_metrics);

        rst_n = 1'b0;
        clear = 1'b0;
        sample_valid = 1'b0;
        finalize = 1'b0;
        sample_in = 16'sd0;
        repeat (4) @(posedge clk);
        rst_n = 1'b1;

        reset_datapath();
        for (i = 0; i < 16; i = i + 1)
            feed_sample(16'sd32767);
        finish_and_check(32'sd524272, 32'sd32767, 32'd1073676289);

        reset_datapath();
        for (i = 0; i < 16; i = i + 1)
            feed_sample(16'sh8000);
        finish_and_check(-32'sd524288, -32'sd32768, 32'd1073741824);

        reset_datapath();
        for (i = 0; i < 8; i = i + 1) begin
            feed_sample(16'sd32767);
            feed_sample(16'sh8000);
        end
        finish_and_check(-32'sd8, 32'sd0, 32'd1073709056);

        $display("PASS: datapath extreme and alternating directed cases");
        $finish;
    end
endmodule
