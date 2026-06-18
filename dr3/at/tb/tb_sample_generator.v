`timescale 1ns/1ps

module tb_sample_generator;
    reg clk;
    reg rst_n;
    reg reseed;
    reg next_sample;

    wire signed [15:0] sample;
    wire [15:0] random_state;

    reg [15:0] expected_state;
    reg signed [15:0] captured_samples [0:15];
    reg signed [15:0] first_reseed_sample;
    reg all_samples_equal;
    integer i;

    sample_generator #(
        .SEED(16'hACE1)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .reseed(reseed),
        .next_sample(next_sample),
        .sample(sample),
        .random_state(random_state)
    );

    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    function [15:0] lfsr_next;
        input [15:0] value;
        begin
            lfsr_next = {value[14:0], value[15] ^ value[13] ^ value[12] ^ value[10]};
        end
    endfunction

    task pulse_reseed;
        begin
            @(negedge clk);
            reseed = 1'b1;
            next_sample = 1'b0;
            @(posedge clk);
            #1;
            reseed = 1'b0;
            expected_state = sample;

            if (sample === 16'h0000) begin
                $display("FAIL: random generator reseeded to zero");
                $finish_and_return(1);
            end
        end
    endtask

    task advance_and_check;
        begin
            expected_state = lfsr_next(expected_state);
            @(negedge clk);
            next_sample = 1'b1;
            reseed = 1'b0;
            @(posedge clk);
            #1;
            next_sample = 1'b0;

            if (sample !== expected_state) begin
                $display("FAIL: LFSR expected 0x%04h got 0x%04h", expected_state, sample);
                $finish_and_return(1);
            end
        end
    endtask

    initial begin
        $dumpfile("build/waves/tb_sample_generator.vcd");
        $dumpvars(0, tb_sample_generator);

        rst_n = 1'b0;
        reseed = 1'b0;
        next_sample = 1'b0;
        repeat (4) @(posedge clk);
        rst_n = 1'b1;
        repeat (4) @(posedge clk);

        pulse_reseed();
        first_reseed_sample = sample;
        captured_samples[0] = sample;

        for (i = 1; i < 16; i = i + 1) begin
            advance_and_check();
            captured_samples[i] = sample;
        end

        all_samples_equal = 1'b1;
        for (i = 1; i < 16; i = i + 1) begin
            if (captured_samples[i] !== captured_samples[0])
                all_samples_equal = 1'b0;
        end

        if (all_samples_equal) begin
            $display("FAIL: random generator produced 16 identical samples");
            $finish_and_return(1);
        end

        repeat (9) @(posedge clk);
        pulse_reseed();

        if (sample === first_reseed_sample) begin
            $display("FAIL: reseed produced the same first sample at a later time");
            $finish_and_return(1);
        end

        $display("PASS: sample generator produced valid pseudo-random LFSR samples");
        $finish;
    end
endmodule
