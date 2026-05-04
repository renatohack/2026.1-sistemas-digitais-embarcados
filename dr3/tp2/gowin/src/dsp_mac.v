`timescale 1ns / 1ps

module dsp_mac #(
    parameter INPUT_WIDTH = 16,
    parameter ACC_WIDTH = 32
) (
    input wire clk,
    input wire rst_n,
    input wire clear,
    input wire valid,
    input wire [INPUT_WIDTH-1:0] a,
    input wire [INPUT_WIDTH-1:0] b,
    output reg [ACC_WIDTH-1:0] acc
);

    wire [ACC_WIDTH-1:0] product;
    assign product = a * b;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            acc <= {ACC_WIDTH{1'b0}};
        end else if (clear) begin
            acc <= {ACC_WIDTH{1'b0}};
        end else if (valid) begin
            acc <= acc + product;
        end
    end

endmodule
