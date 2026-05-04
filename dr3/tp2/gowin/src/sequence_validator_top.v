`timescale 1ns / 1ps

module sequence_validator_top #(
    parameter SHOW_TICKS = 13500000,
    parameter SHOW_TICK_WIDTH = 24,
    parameter DEBOUNCE_TICKS = 135000,
    parameter DEBOUNCE_WIDTH = 18,
    parameter SUCCESS_CYCLE_TICKS = 6750000,
    parameter SUCCESS_CYCLE_WIDTH = 23
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

    localparam BRAM_ADDR_WIDTH = 4;
    localparam BRAM_DATA_WIDTH = 16;
    localparam DSP_INPUT_WIDTH = 16;
    localparam DSP_ACC_WIDTH = 32;

    wire core_clk;
    wire pll_lock;
    wire core_rst_n;
    wire [3:0] button_pressed;
    wire [3:0] button_pulse;
    wire [3:0] base_display_value;
    wire base_display_error;
    wire success_active;
    wire [3:0] success_tens;
    wire [3:0] success_ones;
    wire [3:0] final_display_value;
    wire final_display_error;
    wire final_display_success;
    wire [6:0] seg_bus;
    wire bram_en;
    wire bram_we;
    wire [BRAM_ADDR_WIDTH-1:0] bram_addr;
    wire [BRAM_DATA_WIDTH-1:0] bram_din;
    wire [BRAM_DATA_WIDTH-1:0] bram_dout;
    wire dsp_clear;
    wire dsp_valid;
    wire [DSP_INPUT_WIDTH-1:0] dsp_a;
    wire [DSP_INPUT_WIDTH-1:0] dsp_b;
    wire [DSP_ACC_WIDTH-1:0] dsp_acc;

    wire [3:0] state_debug;
    wire [1:0] step_debug;
    wire [7:0] checksum_debug;
    wire [1:0] success_phase_debug;

    assign core_rst_n = sys_rst_n & pll_lock;

    pll_wrapper pll_wrapper_inst (
        .clkin(sys_clk),
        .reset_n(sys_rst_n),
        .clkout(core_clk),
        .lock(pll_lock)
    );

    genvar button_index;
    generate
        for (button_index = 0; button_index < 4; button_index = button_index + 1) begin : button_inputs
            button_conditioner #(
                .DEBOUNCE_TICKS(DEBOUNCE_TICKS),
                .COUNTER_WIDTH(DEBOUNCE_WIDTH)
            ) button_conditioner_inst (
                .clk(core_clk),
                .rst_n(core_rst_n),
                .raw_n(btn_n[button_index]),
                .pressed(button_pressed[button_index]),
                .pressed_pulse(button_pulse[button_index])
            );
        end
    endgenerate

    sync_bram #(
        .ADDR_WIDTH(BRAM_ADDR_WIDTH),
        .DATA_WIDTH(BRAM_DATA_WIDTH)
    ) sync_bram_inst (
        .clk(core_clk),
        .en(bram_en),
        .we(bram_we),
        .addr(bram_addr),
        .din(bram_din),
        .dout(bram_dout)
    );

    dsp_mac #(
        .INPUT_WIDTH(DSP_INPUT_WIDTH),
        .ACC_WIDTH(DSP_ACC_WIDTH)
    ) dsp_mac_inst (
        .clk(core_clk),
        .rst_n(core_rst_n),
        .clear(dsp_clear),
        .valid(dsp_valid),
        .a(dsp_a),
        .b(dsp_b),
        .acc(dsp_acc)
    );

    sequence_fsm #(
        .SHOW_TICKS(SHOW_TICKS),
        .SHOW_TICK_WIDTH(SHOW_TICK_WIDTH),
        .BRAM_ADDR_WIDTH(BRAM_ADDR_WIDTH),
        .BRAM_DATA_WIDTH(BRAM_DATA_WIDTH),
        .DSP_INPUT_WIDTH(DSP_INPUT_WIDTH),
        .DSP_ACC_WIDTH(DSP_ACC_WIDTH)
    ) sequence_fsm_inst (
        .clk(core_clk),
        .rst_n(core_rst_n),
        .button_pulse(button_pulse),
        .bram_dout(bram_dout),
        .dsp_acc(dsp_acc),
        .led_n(led_n),
        .display_value(base_display_value),
        .display_error(base_display_error),
        .success_active(success_active),
        .success_tens(success_tens),
        .success_ones(success_ones),
        .bram_en(bram_en),
        .bram_we(bram_we),
        .bram_addr(bram_addr),
        .bram_din(bram_din),
        .dsp_clear(dsp_clear),
        .dsp_valid(dsp_valid),
        .dsp_a(dsp_a),
        .dsp_b(dsp_b),
        .state_debug(state_debug),
        .step_debug(step_debug),
        .checksum_debug(checksum_debug)
    );

    result_display_mux #(
        .SUCCESS_CYCLE_TICKS(SUCCESS_CYCLE_TICKS),
        .COUNTER_WIDTH(SUCCESS_CYCLE_WIDTH)
    ) result_display_mux_inst (
        .clk(core_clk),
        .rst_n(core_rst_n),
        .base_value(base_display_value),
        .base_error(base_display_error),
        .success_active(success_active),
        .success_tens(success_tens),
        .success_ones(success_ones),
        .display_value(final_display_value),
        .display_error(final_display_error),
        .display_success(final_display_success),
        .phase_debug(success_phase_debug)
    );

    seven_segment_decoder seven_segment_decoder_inst (
        .value(final_display_value),
        .error(final_display_error),
        .success(final_display_success),
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
