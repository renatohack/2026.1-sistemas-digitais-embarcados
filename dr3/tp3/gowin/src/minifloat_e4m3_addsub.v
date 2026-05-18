`timescale 1ns / 1ps
`default_nettype none

module minifloat_e4m3_addsub (
    input wire op_sub,
    input wire [7:0] a,
    input wire [7:0] b,
    output reg [7:0] result,
    output reg [5:0] flags
);

    localparam FLAG_OVERFLOW = 0;
    localparam FLAG_UNDERFLOW = 1;
    localparam FLAG_DIV_ZERO = 2;
    localparam FLAG_SATURATION = 3;
    localparam FLAG_UNSUPPORTED = 4;
    localparam FLAG_INEXACT = 5;

    localparam [3:0] EXP_INF = 4'hf;
    localparam [19:0] MIN_NORMAL_MAG = 20'd2048;
    localparam [19:0] NEXT_EXP_MAG = 20'd4096;

    reg sign_a;
    reg sign_b;
    reg sign_b_eff;
    reg sign_res;
    reg [3:0] exp_a;
    reg [3:0] exp_b;
    reg [3:0] exp_work;
    reg [3:0] frac_a;
    reg [3:0] frac_b;
    reg [4:0] exp_diff;
    reg [19:0] mag_a;
    reg [19:0] mag_b;
    reg [19:0] aligned_a;
    reg [19:0] aligned_b;
    reg [20:0] shifted_pack;
    reg signed [21:0] signed_a;
    reg signed [21:0] signed_b;
    reg signed [21:0] sum_signed;
    reg [21:0] abs_sum;
    reg [19:0] mag_work;
    reg sticky;
    integer norm_i;

    function [20:0] shift_right_sticky;
        input [19:0] value;
        input [4:0] amount;
        reg [19:0] mask;
        begin
            if (amount == 5'd0) begin
                shift_right_sticky = {1'b0, value};
            end else if (amount >= 5'd20) begin
                shift_right_sticky = {|value, 20'd0};
            end else begin
                mask = (20'd1 << amount) - 20'd1;
                shift_right_sticky = {|(value & mask), value >> amount};
            end
        end
    endfunction

    always @* begin
        result = 8'd0;
        flags = 6'd0;

        sign_a = a[7];
        sign_b = b[7];
        sign_b_eff = b[7] ^ op_sub;
        sign_res = 1'b0;
        exp_a = a[6:3];
        exp_b = b[6:3];
        exp_work = 4'd0;
        frac_a = {1'b1, a[2:0]};
        frac_b = {1'b1, b[2:0]};
        exp_diff = 5'd0;
        mag_a = 20'd0;
        mag_b = 20'd0;
        aligned_a = 20'd0;
        aligned_b = 20'd0;
        shifted_pack = 21'd0;
        signed_a = 22'sd0;
        signed_b = 22'sd0;
        sum_signed = 22'sd0;
        abs_sum = 22'd0;
        mag_work = 20'd0;
        sticky = 1'b0;
        norm_i = 0;

        if ((exp_a == EXP_INF) && (a[2:0] != 3'd0)) begin
            result = 8'h7f;
            flags[FLAG_OVERFLOW] = 1'b1;
            flags[FLAG_INEXACT] = 1'b1;
        end else if ((exp_b == EXP_INF) && (b[2:0] != 3'd0)) begin
            result = 8'h7f;
            flags[FLAG_OVERFLOW] = 1'b1;
            flags[FLAG_INEXACT] = 1'b1;
        end else if ((exp_a == EXP_INF) && (exp_b == EXP_INF) && (sign_a != sign_b_eff)) begin
            result = 8'h7f;
            flags[FLAG_OVERFLOW] = 1'b1;
            flags[FLAG_INEXACT] = 1'b1;
        end else if (exp_a == EXP_INF) begin
            result = {sign_a, EXP_INF, 3'd0};
            flags[FLAG_OVERFLOW] = 1'b1;
        end else if (exp_b == EXP_INF) begin
            result = {sign_b_eff, EXP_INF, 3'd0};
            flags[FLAG_OVERFLOW] = 1'b1;
        end else if ((exp_a == 4'd0) && (a[2:0] == 3'd0) && (exp_b == 4'd0) && (b[2:0] == 3'd0)) begin
            result = 8'd0;
        end else if ((exp_a == 4'd0) && (a[2:0] == 3'd0)) begin
            if (exp_b == 4'd0) begin
                result = 8'd0;
                flags[FLAG_UNDERFLOW] = (b[2:0] != 3'd0);
                flags[FLAG_INEXACT] = (b[2:0] != 3'd0);
            end else begin
                result = {sign_b_eff, exp_b, b[2:0]};
            end
        end else if ((exp_b == 4'd0) && (b[2:0] == 3'd0)) begin
            if (exp_a == 4'd0) begin
                result = 8'd0;
                flags[FLAG_UNDERFLOW] = (a[2:0] != 3'd0);
                flags[FLAG_INEXACT] = (a[2:0] != 3'd0);
            end else begin
                result = a;
            end
        end else if ((exp_a == 4'd0) || (exp_b == 4'd0)) begin
            result = 8'd0;
            flags[FLAG_UNDERFLOW] = 1'b1;
            flags[FLAG_INEXACT] = 1'b1;
        end else begin
            mag_a = {8'd0, frac_a, 8'd0};
            mag_b = {8'd0, frac_b, 8'd0};

            if (exp_a >= exp_b) begin
                exp_work = exp_a;
                exp_diff = {1'b0, exp_a} - {1'b0, exp_b};
                aligned_a = mag_a;
                shifted_pack = shift_right_sticky(mag_b, exp_diff);
                aligned_b = shifted_pack[19:0];
                sticky = shifted_pack[20];
            end else begin
                exp_work = exp_b;
                exp_diff = {1'b0, exp_b} - {1'b0, exp_a};
                aligned_b = mag_b;
                shifted_pack = shift_right_sticky(mag_a, exp_diff);
                aligned_a = shifted_pack[19:0];
                sticky = shifted_pack[20];
            end

            signed_a = sign_a ? -$signed({2'b00, aligned_a}) : $signed({2'b00, aligned_a});
            signed_b = sign_b_eff ? -$signed({2'b00, aligned_b}) : $signed({2'b00, aligned_b});
            sum_signed = signed_a + signed_b;

            if (sum_signed == 22'sd0) begin
                result = 8'd0;
                flags[FLAG_INEXACT] = sticky;
            end else begin
                sign_res = sum_signed[21];
                abs_sum = sign_res ? -sum_signed : sum_signed;
                mag_work = abs_sum[19:0];

                for (norm_i = 0; norm_i < 5; norm_i = norm_i + 1) begin
                    if ((mag_work >= NEXT_EXP_MAG) && (exp_work < EXP_INF)) begin
                        sticky = sticky | mag_work[0];
                        mag_work = mag_work >> 1;
                        exp_work = exp_work + 4'd1;
                    end
                end

                if (exp_work >= EXP_INF) begin
                    result = {sign_res, EXP_INF, 3'd0};
                    flags[FLAG_OVERFLOW] = 1'b1;
                    flags[FLAG_INEXACT] = sticky;
                end else begin
                    for (norm_i = 0; norm_i < 15; norm_i = norm_i + 1) begin
                        if ((mag_work < MIN_NORMAL_MAG) && (exp_work > 4'd0)) begin
                            mag_work = mag_work << 1;
                            exp_work = exp_work - 4'd1;
                        end
                    end

                    if ((exp_work == 4'd0) || (mag_work < MIN_NORMAL_MAG)) begin
                        result = 8'd0;
                        flags[FLAG_UNDERFLOW] = 1'b1;
                        flags[FLAG_INEXACT] = sticky | (mag_work != 20'd0);
                    end else begin
                        result = {sign_res, exp_work, mag_work[10:8]};
                        flags[FLAG_INEXACT] = sticky | (mag_work[7:0] != 8'd0);
                    end
                end
            end
        end

        flags[FLAG_DIV_ZERO] = 1'b0;
        flags[FLAG_SATURATION] = 1'b0;
        flags[FLAG_UNSUPPORTED] = 1'b0;
    end

endmodule

`default_nettype wire
