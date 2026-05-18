`timescale 1ns / 1ps

module tb_int_unsigned_alu;

    reg [1:0] op;
    reg [7:0] a;
    reg [7:0] b;
    wire [7:0] result;
    wire [5:0] flags;
    integer errors;

    int_unsigned_alu dut (
        .op(op),
        .a(a),
        .b(b),
        .result(result),
        .flags(flags)
    );

    initial begin
        $dumpfile("sim/build/tb_int_unsigned_alu.vcd");
        $dumpvars(0, tb_int_unsigned_alu);

        errors = 0;
        check_case(2'd0, 8'd12, 8'd5, 8'd17, 6'b000000, "unsigned add normal");
        check_case(2'd0, 8'd250, 8'd10, 8'd4, 6'b000001, "unsigned add overflow");
        check_case(2'd1, 8'd12, 8'd5, 8'd7, 6'b000000, "unsigned sub normal");
        check_case(2'd1, 8'd5, 8'd12, 8'd249, 6'b000010, "unsigned sub underflow");
        check_case(2'd2, 8'd12, 8'd5, 8'd60, 6'b000000, "unsigned mul normal");
        check_case(2'd2, 8'd20, 8'd20, 8'd144, 6'b000001, "unsigned mul overflow");
        check_case(2'd3, 8'd20, 8'd5, 8'd4, 6'b000000, "unsigned div exact");
        check_case(2'd3, 8'd7, 8'd2, 8'd3, 6'b100000, "unsigned div inexact");
        check_case(2'd3, 8'd7, 8'd0, 8'd0, 6'b000100, "unsigned div zero");

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
