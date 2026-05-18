`timescale 1ns / 1ps
`default_nettype none

module int_unsigned_alu (
    input wire [1:0] op,
    input wire [7:0] a,
    input wire [7:0] b,
    output reg [7:0] result,
    output reg [5:0] flags
);

    localparam OP_ADD = 2'b00;
    localparam OP_SUB = 2'b01;
    localparam OP_MUL = 2'b10;
    localparam OP_DIV = 2'b11;

    localparam FLAG_OVERFLOW = 0;
    localparam FLAG_UNDERFLOW = 1;
    localparam FLAG_DIV_ZERO = 2;
    localparam FLAG_SATURATION = 3;
    localparam FLAG_UNSUPPORTED = 4;
    localparam FLAG_INEXACT = 5;

    reg [8:0] add_tmp;
    reg [8:0] sub_tmp;
    reg [15:0] mul_tmp;
    reg [7:0] div_tmp;
    reg [7:0] rem_tmp;

    always @* begin
        result = 8'd0;
        flags = 6'd0;
        add_tmp = 9'd0;
        sub_tmp = 9'd0;
        mul_tmp = 16'd0;
        div_tmp = 8'd0;
        rem_tmp = 8'd0;

        case (op)
            OP_ADD: begin
                add_tmp = {1'b0, a} + {1'b0, b};
                result = add_tmp[7:0];
                flags[FLAG_OVERFLOW] = add_tmp[8];
            end

            OP_SUB: begin
                sub_tmp = {1'b0, a} - {1'b0, b};
                result = sub_tmp[7:0];
                flags[FLAG_UNDERFLOW] = (a < b);
            end

            OP_MUL: begin
                mul_tmp = a * b;
                result = mul_tmp[7:0];
                flags[FLAG_OVERFLOW] = |mul_tmp[15:8];
            end

            OP_DIV: begin
                if (b == 8'd0) begin
                    result = 8'd0;
                    flags[FLAG_DIV_ZERO] = 1'b1;
                end else begin
                    div_tmp = a / b;
                    rem_tmp = a % b;
                    result = div_tmp;
                    flags[FLAG_INEXACT] = (rem_tmp != 8'd0);
                end
            end

            default: begin
                result = 8'd0;
                flags[FLAG_UNSUPPORTED] = 1'b1;
            end
        endcase

        flags[FLAG_SATURATION] = 1'b0;
    end

endmodule

`default_nettype wire
