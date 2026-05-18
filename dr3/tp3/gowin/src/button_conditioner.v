`timescale 1ns / 1ps
`default_nettype none

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

    localparam [COUNTER_WIDTH-1:0] DEBOUNCE_LIMIT = DEBOUNCE_TICKS - 1;

    reg sync_0;
    reg sync_1;
    reg stable_n;
    reg debounced_pressed;
    reg debounced_pressed_d;
    reg [COUNTER_WIDTH-1:0] counter;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            sync_0 <= 1'b1;
            sync_1 <= 1'b1;
            stable_n <= 1'b1;
            debounced_pressed <= 1'b0;
            debounced_pressed_d <= 1'b0;
            pressed <= 1'b0;
            pressed_pulse <= 1'b0;
            counter <= {COUNTER_WIDTH{1'b0}};
        end else begin
            sync_0 <= raw_n;
            sync_1 <= sync_0;

            if (sync_1 == stable_n) begin
                counter <= {COUNTER_WIDTH{1'b0}};
            end else if (counter == DEBOUNCE_LIMIT) begin
                stable_n <= sync_1;
                counter <= {COUNTER_WIDTH{1'b0}};
            end else begin
                counter <= counter + {{(COUNTER_WIDTH-1){1'b0}}, 1'b1};
            end

            debounced_pressed <= ~stable_n;
            debounced_pressed_d <= debounced_pressed;
            pressed <= debounced_pressed;
            pressed_pulse <= debounced_pressed & ~debounced_pressed_d;
        end
    end

endmodule

`default_nettype wire
