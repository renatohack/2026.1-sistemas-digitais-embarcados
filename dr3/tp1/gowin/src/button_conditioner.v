`timescale 1ns / 1ps

module button_conditioner #(
    parameter DEBOUNCE_TICKS = 270000,
    parameter COUNTER_WIDTH = 19
) (
    input wire clk,
    input wire rst_n,
    input wire raw_n,
    output reg pressed,
    output reg pressed_pulse
);

    reg sync_0;
    reg sync_1;
    reg [COUNTER_WIDTH-1:0] debounce_count;

    wire sampled_pressed;
    assign sampled_pressed = ~sync_1;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            sync_0 <= 1'b1;
            sync_1 <= 1'b1;
        end else begin
            sync_0 <= raw_n;
            sync_1 <= sync_0;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pressed <= 1'b0;
            pressed_pulse <= 1'b0;
            debounce_count <= {COUNTER_WIDTH{1'b0}};
        end else begin
            pressed_pulse <= 1'b0;

            if (sampled_pressed == pressed) begin
                debounce_count <= {COUNTER_WIDTH{1'b0}};
            end else if (debounce_count == DEBOUNCE_TICKS - 1) begin
                pressed <= sampled_pressed;
                pressed_pulse <= sampled_pressed;
                debounce_count <= {COUNTER_WIDTH{1'b0}};
            end else begin
                debounce_count <= debounce_count + 1'b1;
            end
        end
    end

endmodule
