`timescale 1ns / 1ps

module tb_dsp_mac;

    reg clk;
    reg rst_n;
    reg clear;
    reg valid;
    reg [15:0] a;
    reg [15:0] b;
    wire [31:0] acc;
    integer errors;

    dsp_mac dut (
        .clk(clk),
        .rst_n(rst_n),
        .clear(clear),
        .valid(valid),
        .a(a),
        .b(b),
        .acc(acc)
    );

    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    initial begin
        $dumpfile("sim/build/tb_dsp_mac.vcd");
        $dumpvars(0, tb_dsp_mac);

        errors = 0;
        rst_n = 1'b0;
        clear = 1'b0;
        valid = 1'b0;
        a = 16'd0;
        b = 16'd0;

        repeat (3) @(posedge clk);
        rst_n = 1'b1;
        repeat (1) @(posedge clk);

        clear_accumulator;
        check(acc == 32'd0, "accumulator clears to zero");

        mac_step(16'd1, 16'd1, 32'd1, "step 0 contributes 1");
        mac_step(16'd3, 16'd2, 32'd7, "step 1 contributes 6");
        mac_step(16'd2, 16'd3, 32'd13, "step 2 contributes 6");
        mac_step(16'd4, 16'd4, 32'd29, "step 3 contributes 16 and total is 29");

        if (errors == 0) begin
            $display("ALL TESTS PASSED");
            $finish;
        end else begin
            $display("TESTS FAILED: %0d error(s)", errors);
            $fatal;
        end
    end

    task check;
        input condition;
        input [1023:0] message;
        begin
            if (!condition) begin
                $display("FAIL: %0s", message);
                errors = errors + 1;
            end else begin
                $display("PASS: %0s", message);
            end
        end
    endtask

    task clear_accumulator;
        begin
            @(negedge clk);
            clear = 1'b1;
            @(posedge clk);
            @(negedge clk);
            clear = 1'b0;
        end
    endtask

    task mac_step;
        input [15:0] step_a;
        input [15:0] step_b;
        input [31:0] expected_acc;
        input [1023:0] message;
        begin
            @(negedge clk);
            valid = 1'b1;
            a = step_a;
            b = step_b;
            @(posedge clk);
            @(negedge clk);
            valid = 1'b0;
            a = 16'd0;
            b = 16'd0;
            check(acc == expected_acc, message);
        end
    endtask

endmodule
