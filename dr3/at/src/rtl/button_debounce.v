`timescale 1ns/1ps

module button_debounce #(
    parameter integer DEBOUNCE_CYCLES = 270000
) (
    input clk,
    input rst_n,
    input button_n,
    output reg pressed,
    output reg pressed_pulse
);
    reg sync_0;
    reg sync_1;
    reg stable_level;
    reg previous_pressed;
    reg [31:0] counter;

    wire sampled_level;

    assign sampled_level = ~sync_1;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            sync_0 <= 1'b1;
            sync_1 <= 1'b1;
            stable_level <= 1'b0;
            previous_pressed <= 1'b0;
            pressed <= 1'b0;
            pressed_pulse <= 1'b0;
            counter <= 32'd0;
        end else begin
            sync_0 <= button_n;
            sync_1 <= sync_0;
            pressed_pulse <= 1'b0;

            if (sampled_level == stable_level) begin
                counter <= 32'd0;
            end else if (counter >= DEBOUNCE_CYCLES - 1) begin
                stable_level <= sampled_level;
                counter <= 32'd0;
            end else begin
                counter <= counter + 32'd1;
            end

            pressed <= stable_level;
            previous_pressed <= pressed;

            if (pressed && !previous_pressed)
                pressed_pulse <= 1'b1;
        end
    end
endmodule

