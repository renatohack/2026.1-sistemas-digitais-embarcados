`timescale 1ns / 1ps

module tb_minifloat_e4m3_addsub;

    reg op_sub;
    reg [7:0] a;
    reg [7:0] b;
    wire [7:0] result;
    wire [5:0] flags;
    integer errors;

    minifloat_e4m3_addsub dut (
        .op_sub(op_sub),
        .a(a),
        .b(b),
        .result(result),
        .flags(flags)
    );

    initial begin
        $dumpfile("sim/build/tb_minifloat_e4m3_addsub.vcd");
        $dumpvars(0, tb_minifloat_e4m3_addsub);

        errors = 0;
        check_case(1'b0, 8'h38, 8'h30, 8'h3c, 6'b000000, "float add 1.0 + 0.5");
        check_case(1'b0, 8'h77, 8'h77, 8'h78, 6'b000001, "float add overflow to infinity");
        check_case(1'b0, 8'h38, 8'hb8, 8'h00, 6'b000000, "float add cancellation to zero");
        check_case(1'b0, 8'h08, 8'h89, 8'h00, 6'b100010, "float add underflow to zero");
        check_case(1'b1, 8'h38, 8'h30, 8'h30, 6'b000000, "float sub 1.0 - 0.5");
        check_case(1'b1, 8'h30, 8'h38, 8'hb0, 6'b000000, "float sub negative result");
        check_case(1'b1, 8'h77, 8'hf7, 8'h78, 6'b000001, "float sub overflow to infinity");
        check_case(1'b1, 8'h08, 8'h09, 8'h00, 6'b100010, "float sub underflow to zero");

        finish_test;
    end

    task check_case;
        input t_op_sub;
        input [7:0] t_a;
        input [7:0] t_b;
        input [7:0] exp_result;
        input [5:0] exp_flags;
        input [1023:0] message;
        begin
            op_sub = t_op_sub;
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
