`timescale 1ns/1ps

module sample_bram #(
    parameter DATA_WIDTH = 16,
    parameter ADDR_WIDTH = 4
) (
    input clk,
    input we,
    input [ADDR_WIDTH-1:0] addr,
    input signed [DATA_WIDTH-1:0] din,
    output reg signed [DATA_WIDTH-1:0] dout
);
    reg [DATA_WIDTH-1:0] mem [0:(1 << ADDR_WIDTH)-1] /* synthesis syn_ramstyle = "block_ram" */;

    always @(posedge clk) begin
        if (we)
            mem[addr] <= din;

        dout <= mem[addr];
    end
endmodule

