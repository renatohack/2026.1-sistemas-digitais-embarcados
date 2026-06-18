`timescale 1ns/1ps

module sample_generator #(
    parameter [15:0] SEED = 16'hACE1
) (
    input clk,
    input rst_n,
    input reseed,
    input next_sample,
    output reg signed [15:0] sample,
    output [15:0] random_state
);
    localparam [15:0] ENTROPY_STEP = 16'h1D3D;

    reg [15:0] lfsr;
    reg [15:0] entropy_counter;

    wire feedback;
    wire [15:0] lfsr_next;
    wire [15:0] mixed_seed;
    wire [15:0] reseed_value;

    assign feedback = lfsr[15] ^ lfsr[13] ^ lfsr[12] ^ lfsr[10];
    assign lfsr_next = {lfsr[14:0], feedback};
    assign mixed_seed = SEED ^ entropy_counter ^ {entropy_counter[7:0], entropy_counter[15:8]};
    assign reseed_value = (mixed_seed == 16'h0000) ? SEED : mixed_seed;
    assign random_state = lfsr;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            lfsr <= SEED;
            entropy_counter <= 16'd0;
            sample <= SEED;
        end else begin
            entropy_counter <= entropy_counter + ENTROPY_STEP;

            if (reseed) begin
                lfsr <= reseed_value;
                sample <= reseed_value;
            end else if (next_sample) begin
                lfsr <= lfsr_next;
                sample <= lfsr_next;
            end
        end
    end
endmodule
