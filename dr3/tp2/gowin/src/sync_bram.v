`timescale 1ns / 1ps

module sync_bram #(
    parameter ADDR_WIDTH = 4,
    parameter DATA_WIDTH = 16
) (
    input wire clk,
    input wire en,
    input wire we,
    input wire [ADDR_WIDTH-1:0] addr,
    input wire [DATA_WIDTH-1:0] din,
    output reg [DATA_WIDTH-1:0] dout
);

    (* syn_ramstyle = "block_ram" *)
    reg [DATA_WIDTH-1:0] mem [0:(1 << ADDR_WIDTH) - 1];

    integer index;
    initial begin
        dout = {DATA_WIDTH{1'b0}};
        for (index = 0; index < (1 << ADDR_WIDTH); index = index + 1) begin
            mem[index] = {DATA_WIDTH{1'b0}};
        end
    end

    always @(posedge clk) begin
        if (en) begin
            if (we) begin
                mem[addr] <= din;
            end
            dout <= mem[addr];
        end
    end

endmodule
