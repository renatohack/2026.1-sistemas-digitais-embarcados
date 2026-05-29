`timescale 1ns/1ps

module arithmetic_datapath (
    input clk,
    input rst_n,
    input clear,
    input sample_valid,
    input finalize,
    input signed [15:0] sample_in,
    output reg signed [31:0] sum_acc,
    output reg [39:0] sumsq_acc,
    output reg signed [31:0] sum_out,
    output reg signed [31:0] mean_out,
    output reg [31:0] rms2_out,
    output reg [4:0] sample_count,
    output reg done,
    output reg overflow
);
    wire signed [31:0] sample_ext;
    wire signed [31:0] square_product /* synthesis syn_dspstyle = "dsp" */;
    wire signed [32:0] next_sum_ext;
    wire [40:0] next_sumsq_ext;

    assign sample_ext = {{16{sample_in[15]}}, sample_in};
    assign square_product = sample_in * sample_in;
    assign next_sum_ext = {sum_acc[31], sum_acc} + {sample_ext[31], sample_ext};
    assign next_sumsq_ext = {1'b0, sumsq_acc} + {9'd0, square_product[31:0]};

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            sum_acc <= 32'sd0;
            sumsq_acc <= 40'd0;
            sum_out <= 32'sd0;
            mean_out <= 32'sd0;
            rms2_out <= 32'd0;
            sample_count <= 5'd0;
            done <= 1'b0;
            overflow <= 1'b0;
        end else if (clear) begin
            sum_acc <= 32'sd0;
            sumsq_acc <= 40'd0;
            sum_out <= 32'sd0;
            mean_out <= 32'sd0;
            rms2_out <= 32'd0;
            sample_count <= 5'd0;
            done <= 1'b0;
            overflow <= 1'b0;
        end else begin
            done <= 1'b0;

            if (sample_valid) begin
                sum_acc <= next_sum_ext[31:0];
                sumsq_acc <= next_sumsq_ext[39:0];
                sample_count <= sample_count + 5'd1;

                if (next_sum_ext[32] != next_sum_ext[31])
                    overflow <= 1'b1;

                if (next_sumsq_ext[40])
                    overflow <= 1'b1;
            end

            if (finalize) begin
                sum_out <= sum_acc;
                mean_out <= sum_acc / 32'sd16;
                rms2_out <= sumsq_acc / 40'd16;
                done <= 1'b1;
            end
        end
    end
endmodule

