`timescale 1ns / 1ps

module tb_int_signed_alu;

    reg [1:0] op;
    reg [7:0] a;
    reg [7:0] b;
    wire [7:0] result;
    wire [5:0] flags;
    integer errors;

    int_signed_alu dut (
        .op(op),
        .a(a),
        .b(b),
        .result(result),
        .flags(flags)
    );

    initial begin
        $dumpfile("sim/build/tb_int_signed_alu.vcd");
        $dumpvars(0, tb_int_signed_alu);

        errors = 0;
        check_case(2'd0, 8'd10, 8'd5, 8'd15, 6'b000000, "signed add normal");
        check_case(2'd0, 8'd100, 8'd40, 8'd140, 6'b000001, "signed add positive overflow");
        check_case(2'd0, 8'hce, 8'hb0, 8'd126, 6'b000010, "signed add negative underflow");
        check_case(2'd1, 8'd10, 8'd5, 8'd5, 6'b000000, "signed sub normal");
        check_case(2'd1, 8'h9c, 8'd40, 8'd116, 6'b000010, "signed sub negative underflow");
        check_case(2'd1, 8'd100, 8'hd8, 8'd140, 6'b000001, "signed sub positive overflow");
        check_case(2'd2, 8'hfc, 8'd6, 8'he8, 6'b000000, "signed mul normal");
        check_case(2'd2, 8'd50, 8'd5, 8'hfa, 6'b000001, "signed mul overflow");
        check_case(2'd2, 8'hc4, 8'd3, 8'd76, 6'b000010, "signed mul underflow");
        check_case(2'd3, 8'hec, 8'd5, 8'hfc, 6'b000000, "signed div exact");
        check_case(2'd3, 8'd7, 8'd2, 8'd3, 6'b100000, "signed div inexact");
        check_case(2'd3, 8'hf9, 8'd2, 8'hfd, 6'b100000, "signed negative div inexact");
        check_case(2'd3, 8'd7, 8'd0, 8'd0, 6'b000100, "signed div zero");
        check_case(2'd3, 8'h80, 8'hff, 8'h80, 6'b000001, "signed min divided by minus one overflow");

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
