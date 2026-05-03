`timescale 1ns / 1ps

module sequence_validator_top #(
    parameter DISPLAY_TICKS = 27000000,
    parameter TICK_WIDTH = 25,
    parameter DEBOUNCE_TICKS = 270000,
    parameter DEBOUNCE_WIDTH = 19
) (
    input wire sys_clk,
    input wire sys_rst_n,
    input wire [3:0] btn_n,
    output wire [3:0] led_n,
    output wire seg_a,
    output wire seg_b,
    output wire seg_c,
    output wire seg_d,
    output wire seg_e,
    output wire seg_f,
    output wire seg_g
);

    wire [3:0] button_pressed;
    wire [3:0] button_pulse;
    wire [3:0] display_value;
    wire [6:0] seg_bus;
    wire display_error;
    wire display_success;
    wire [2:0] state_debug;
    wire [1:0] step_debug;

    genvar button_index;
    generate
        for (button_index = 0; button_index < 4; button_index = button_index + 1) begin : button_inputs
            button_conditioner #(
                .DEBOUNCE_TICKS(DEBOUNCE_TICKS),
                .COUNTER_WIDTH(DEBOUNCE_WIDTH)
            ) button_conditioner_inst (
                .clk(sys_clk),
                .rst_n(sys_rst_n),
                .raw_n(btn_n[button_index]),
                .pressed(button_pressed[button_index]),
                .pressed_pulse(button_pulse[button_index])
            );
        end
    endgenerate

    sequence_fsm #(
        .DISPLAY_TICKS(DISPLAY_TICKS),
        .TICK_WIDTH(TICK_WIDTH)
    ) sequence_fsm_inst (
        .clk(sys_clk),
        .rst_n(sys_rst_n),
        .button_pulse(button_pulse),
        .led_n(led_n),
        .display_value(display_value),
        .display_error(display_error),
        .display_success(display_success),
        .state_debug(state_debug),
        .step_debug(step_debug)
    );

    seven_segment_decoder seven_segment_decoder_inst (
        .value(display_value),
        .error(display_error),
        .success(display_success),
        .seg(seg_bus)
    );

    assign seg_a = seg_bus[0];
    assign seg_b = seg_bus[1];
    assign seg_c = seg_bus[2];
    assign seg_d = seg_bus[3];
    assign seg_e = seg_bus[4];
    assign seg_f = seg_bus[5];
    assign seg_g = seg_bus[6];

endmodule
