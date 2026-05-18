`timescale 1ns / 1ps
`default_nettype none

module int_signed_alu (
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

    wire signed [7:0] a_s;
    wire signed [7:0] b_s;

    reg signed [8:0] addsub_tmp;
    reg signed [15:0] mul_tmp;
    reg signed [7:0] div_tmp;
    reg signed [7:0] rem_tmp;

    assign a_s = a;
    assign b_s = b;

    always @* begin
        result = 8'd0;
        flags = 6'd0;
        addsub_tmp = 9'sd0;
        mul_tmp = 16'sd0;
        div_tmp = 8'sd0;
        rem_tmp = 8'sd0;

        case (op)
            OP_ADD: begin
                addsub_tmp = {a_s[7], a_s} + {b_s[7], b_s};
                result = addsub_tmp[7:0];
                flags[FLAG_OVERFLOW] = (addsub_tmp > 9'sd127);
                flags[FLAG_UNDERFLOW] = (addsub_tmp < -9'sd128);
            end

            OP_SUB: begin
                addsub_tmp = {a_s[7], a_s} - {b_s[7], b_s};
                result = addsub_tmp[7:0];
                flags[FLAG_OVERFLOW] = (addsub_tmp > 9'sd127);
                flags[FLAG_UNDERFLOW] = (addsub_tmp < -9'sd128);
            end

            OP_MUL: begin
                mul_tmp = a_s * b_s;
                result = mul_tmp[7:0];
                flags[FLAG_OVERFLOW] = (mul_tmp > 16'sd127);
                flags[FLAG_UNDERFLOW] = (mul_tmp < -16'sd128);
            end

            OP_DIV: begin
                if (b_s == 8'sd0) begin
                    result = 8'd0;
                    flags[FLAG_DIV_ZERO] = 1'b1;
                end else if ((a_s == -8'sd128) && (b_s == -8'sd1)) begin
                    result = 8'h80;
                    flags[FLAG_OVERFLOW] = 1'b1;
                end else begin
                    div_tmp = a_s / b_s;
                    rem_tmp = a_s % b_s;
                    result = div_tmp;
                    flags[FLAG_INEXACT] = (rem_tmp != 8'sd0);
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
