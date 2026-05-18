`timescale 1ns / 1ps
`default_nettype none

module fixed_q3_4_alu (
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

    localparam signed [15:0] Q_MAX = 16'sd127;
    localparam signed [15:0] Q_MIN = -16'sd128;

    wire signed [7:0] a_s;
    wire signed [7:0] b_s;

    reg signed [15:0] tmp;
    reg signed [15:0] shifted;
    reg signed [15:0] dividend;
    reg signed [15:0] divisor;
    reg signed [15:0] quotient;
    reg signed [15:0] remainder;
    reg signed [15:0] saturated;
    reg [3:0] lost_bits;

    assign a_s = a;
    assign b_s = b;

    always @* begin
        result = 8'd0;
        flags = 6'd0;
        tmp = 16'sd0;
        shifted = 16'sd0;
        dividend = 16'sd0;
        divisor = 16'sd0;
        quotient = 16'sd0;
        remainder = 16'sd0;
        saturated = 16'sd0;
        lost_bits = 4'd0;

        case (op)
            OP_ADD: begin
                tmp = {{8{a_s[7]}}, a_s} + {{8{b_s[7]}}, b_s};
                saturated = tmp;
                if (tmp > Q_MAX) begin
                    saturated = Q_MAX;
                    flags[FLAG_OVERFLOW] = 1'b1;
                    flags[FLAG_SATURATION] = 1'b1;
                end else if (tmp < Q_MIN) begin
                    saturated = Q_MIN;
                    flags[FLAG_UNDERFLOW] = 1'b1;
                    flags[FLAG_SATURATION] = 1'b1;
                end
                result = saturated[7:0];
            end

            OP_SUB: begin
                tmp = {{8{a_s[7]}}, a_s} - {{8{b_s[7]}}, b_s};
                saturated = tmp;
                if (tmp > Q_MAX) begin
                    saturated = Q_MAX;
                    flags[FLAG_OVERFLOW] = 1'b1;
                    flags[FLAG_SATURATION] = 1'b1;
                end else if (tmp < Q_MIN) begin
                    saturated = Q_MIN;
                    flags[FLAG_UNDERFLOW] = 1'b1;
                    flags[FLAG_SATURATION] = 1'b1;
                end
                result = saturated[7:0];
            end

            OP_MUL: begin
                tmp = a_s * b_s;
                lost_bits = tmp[3:0];
                shifted = tmp >>> 4;
                saturated = shifted;
                flags[FLAG_INEXACT] = (lost_bits != 4'd0);
                if (shifted > Q_MAX) begin
                    saturated = Q_MAX;
                    flags[FLAG_OVERFLOW] = 1'b1;
                    flags[FLAG_SATURATION] = 1'b1;
                end else if (shifted < Q_MIN) begin
                    saturated = Q_MIN;
                    flags[FLAG_UNDERFLOW] = 1'b1;
                    flags[FLAG_SATURATION] = 1'b1;
                end
                result = saturated[7:0];
            end

            OP_DIV: begin
                if (b_s == 8'sd0) begin
                    result = 8'd0;
                    flags[FLAG_DIV_ZERO] = 1'b1;
                end else begin
                    dividend = {{8{a_s[7]}}, a_s} <<< 4;
                    divisor = {{8{b_s[7]}}, b_s};
                    quotient = dividend / divisor;
                    remainder = dividend % divisor;
                    saturated = quotient;
                    flags[FLAG_INEXACT] = (remainder != 16'sd0);
                    if (quotient > Q_MAX) begin
                        saturated = Q_MAX;
                        flags[FLAG_OVERFLOW] = 1'b1;
                        flags[FLAG_SATURATION] = 1'b1;
                    end else if (quotient < Q_MIN) begin
                        saturated = Q_MIN;
                        flags[FLAG_UNDERFLOW] = 1'b1;
                        flags[FLAG_SATURATION] = 1'b1;
                    end
                    result = saturated[7:0];
                end
            end

            default: begin
                result = 8'd0;
                flags[FLAG_UNSUPPORTED] = 1'b1;
            end
        endcase
    end

endmodule

`default_nettype wire
