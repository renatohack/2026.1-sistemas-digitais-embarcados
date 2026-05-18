`timescale 1ns / 1ps

module tb_fixed_q3_4_alu;

    reg [1:0] op;
    reg [7:0] a;
    reg [7:0] b;
    wire [7:0] result;
    wire [5:0] flags;
    integer errors;

    fixed_q3_4_alu dut (
        .op(op),
        .a(a),
        .b(b),
        .result(result),
        .flags(flags)
    );

    initial begin
        $dumpfile("sim/build/tb_fixed_q3_4_alu.vcd");
        $dumpvars(0, tb_fixed_q3_4_alu);

        errors = 0;
        check_case(2'd0, 8'd24, 8'd8, 8'd32, 6'b000000, "fixed add 1.5 + 0.5");
        check_case(2'd0, 8'd120, 8'd16, 8'd127, 6'b001001, "fixed add positive saturation");
        check_case(2'd0, 8'h88, 8'hf0, 8'h80, 6'b001010, "fixed add negative saturation");
        check_case(2'd1, 8'd24, 8'd8, 8'd16, 6'b000000, "fixed sub 1.5 - 0.5");
        check_case(2'd1, 8'h88, 8'd16, 8'h80, 6'b001010, "fixed sub negative saturation");
        check_case(2'd1, 8'd120, 8'hf0, 8'd127, 6'b001001, "fixed sub positive saturation");
        check_case(2'd2, 8'd24, 8'd8, 8'd12, 6'b000000, "fixed mul exact");
        check_case(2'd2, 8'd120, 8'd32, 8'd127, 6'b001001, "fixed mul positive saturation");
        check_case(2'd2, 8'h88, 8'd32, 8'h80, 6'b001010, "fixed mul negative saturation");
        check_case(2'd2, 8'd5, 8'd5, 8'd1, 6'b100000, "fixed mul truncation");
        check_case(2'd3, 8'd24, 8'd8, 8'd48, 6'b000000, "fixed div exact");
        check_case(2'd3, 8'd16, 8'd48, 8'd5, 6'b100000, "fixed div truncation");
        check_case(2'd3, 8'h80, 8'd8, 8'h80, 6'b001010, "fixed div negative saturation");
        check_case(2'd3, 8'd16, 8'd0, 8'd0, 6'b000100, "fixed div zero");

        finish_test;
    end

    task check_case;
        input [1:0] t_op;
        input [7:0] t_a;
        input [7:0] t_b;
        input [7:0] exp_result;
        input [5:0] exp_flags;
        input [1023:0] message;
        begin
            op = t_op;
            a = t_a;
            b = t_b;
            #1;
            if ((result !== exp_result) || (flags !== exp_flags)) begin
                $display("FAIL: %0s result=%02h expected=%02h flags=%02h expected_flags=%02h",
                    message, result, exp_result, flags, exp_flags);
                errors = errors + 1;
            end else begin
                $display("PASS: %0s", message);
            end
        end
    endtask

    task finish_test;
        begin
            if (errors == 0) begin
                $display("ALL TESTS PASSED");
                $finish;
            end else begin
                $display("TESTS FAILED: %0d error(s)", errors);
                $fatal;
            end
        end
    endtask

endmodule
