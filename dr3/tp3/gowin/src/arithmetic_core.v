`timescale 1ns / 1ps
`default_nettype none

module arithmetic_core (
    input wire [1:0] mode,
    input wire [1:0] op,
    input wire [7:0] a,
    input wire [7:0] b,
    output reg [7:0] result,
    output reg [5:0] flags
);

    localparam MODE_UNSIGNED = 2'b00;
    localparam MODE_SIGNED = 2'b01;
    localparam MODE_FIXED = 2'b10;
    localparam MODE_FLOAT = 2'b11;

    localparam OP_ADD = 2'b00;
    localparam OP_SUB = 2'b01;

    localparam FLAG_UNSUPPORTED = 4;

    wire [7:0] unsigned_result;
    wire [5:0] unsigned_flags;
    wire [7:0] signed_result;
    wire [5:0] signed_flags;
    wire [7:0] fixed_result;
    wire [5:0] fixed_flags;
    wire [7:0] float_result;
    wire [5:0] float_flags;

    int_unsigned_alu int_unsigned_alu_inst (
        .op(op),
        .a(a),
        .b(b),
        .result(unsigned_result),
        .flags(unsigned_flags)
    );

    int_signed_alu int_signed_alu_inst (
        .op(op),
        .a(a),
        .b(b),
        .result(signed_result),
        .flags(signed_flags)
    );

    fixed_q3_4_alu fixed_q3_4_alu_inst (
        .op(op),
        .a(a),
        .b(b),
        .result(fixed_result),
        .flags(fixed_flags)
    );

    minifloat_e4m3_addsub minifloat_e4m3_addsub_inst (
        .op_sub(op == OP_SUB),
        .a(a),
        .b(b),
        .result(float_result),
        .flags(float_flags)
    );

    always @* begin
        result = 8'd0;
        flags = 6'd0;

        case (mode)
            MODE_UNSIGNED: begin
                result = unsigned_result;
                flags = unsigned_flags;
            end

            MODE_SIGNED: begin
                result = signed_result;
                flags = signed_flags;
            end

            MODE_FIXED: begin
                result = fixed_result;
                flags = fixed_flags;
            end

            MODE_FLOAT: begin
                if ((op == OP_ADD) || (op == OP_SUB)) begin
                    result = float_result;
                    flags = float_flags;
                end else begin
                    result = 8'd0;
                    flags = 6'd0;
                    flags[FLAG_UNSUPPORTED] = 1'b1;
                end
            end

            default: begin
                result = 8'd0;
                flags = 6'd0;
                flags[FLAG_UNSUPPORTED] = 1'b1;
            end
        endcase
    end

endmodule

`default_nettype wire
