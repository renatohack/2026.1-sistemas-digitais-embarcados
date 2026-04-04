`timescale 1ns / 1ps

module button_debouncer #(
    parameter integer STABLE_CYCLES = 270000
) (
    input  wire clk,
    input  wire noisy_in,
    output reg  debounced_out = 1'b0
);
    localparam integer COUNTER_WIDTH = (STABLE_CYCLES <= 1) ? 1 : $clog2(STABLE_CYCLES);

    reg [COUNTER_WIDTH-1:0] stable_counter = {COUNTER_WIDTH{1'b0}};
    reg sampled_state = 1'b0;

    always @(posedge clk) begin
        if (noisy_in == sampled_state) begin
            stable_counter <= {COUNTER_WIDTH{1'b0}};
        end else if (stable_counter == STABLE_CYCLES - 1) begin
            sampled_state <= noisy_in;
            debounced_out <= noisy_in;
            stable_counter <= {COUNTER_WIDTH{1'b0}};
        end else begin
            stable_counter <= stable_counter + 1'b1;
        end
    end
endmodule
