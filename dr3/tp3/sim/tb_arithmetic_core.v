`timescale 1ns / 1ps

module tb_arithmetic_core;

    reg [1:0] mode;
    reg [1:0] op;
    reg [1:0] case_id;
    wire [7:0] a;
    wire [7:0] b;
    wire [7:0] expected;
    wire [5:0] expected_flags;
    wire [7:0] result;
    wire [5:0] flags;
    integer errors;
    integer mode_i;
    integer op_i;
    integer case_i;

    tp3_demo_vectors vectors (
        .mode(mode),
        .op(op),
        .case_id(case_id),
        .a(a),
        .b(b),
        .expected(expected),
        .expected_flags(expected_flags)
    );

    arithmetic_core dut (
        .mode(mode),
        .op(op),
        .a(a),
        .b(b),
        .result(result),
        .flags(flags)
    );

    initial begin
        $dumpfile("sim/build/tb_arithmetic_core.vcd");
        $dumpvars(0, tb_arithmetic_core);

        errors = 0;
        for (mode_i = 0; mode_i < 4; mode_i = mode_i + 1) begin
            for (op_i = 0; op_i < 4; op_i = op_i + 1) begin
                for (case_i = 0; case_i < 4; case_i = case_i + 1) begin
                    mode = mode_i[1:0];
                    op = op_i[1:0];
                    case_id = case_i[1:0];
                    #1;
                    if ((result !== expected) || (flags !== expected_flags)) begin
                        $display("FAIL: mode=%0d op=%0d case=%0d a=%02h b=%02h result=%02h expected=%02h flags=%02h expected_flags=%02h",
                            mode_i, op_i, case_i, a, b, result, expected, flags, expected_flags);
                        errors = errors + 1;
                    end else begin
                        $display("PASS: mode=%0d op=%0d case=%0d result=%02h flags=%02h",
                            mode_i, op_i, case_i, result, flags);
                    end
                end
            end
        end

        if (errors == 0) begin
            $display("ALL TESTS PASSED");
            $finish;
        end else begin
            $display("TESTS FAILED: %0d error(s)", errors);
            $fatal;
        end
    end

endmodule
