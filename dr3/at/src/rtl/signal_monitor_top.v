`timescale 1ns/1ps

module signal_monitor_top (
    input clk,
    input rst_n,
    input start_n,
    output uart_tx,
    output [5:0] led
);
    wire clk_proc;
    wire pll_locked;
    wire core_rst_n;
    wire start_pressed;
    wire start_pulse;

    assign core_rst_n = rst_n & pll_locked;

    pll_54mhz pll_54mhz_inst (
        .clkin(clk),
        .reset(~rst_n),
        .clkout(clk_proc),
        .lock(pll_locked)
    );

    button_debounce #(
        .DEBOUNCE_CYCLES(270000)
    ) start_button_debounce (
        .clk(clk_proc),
        .rst_n(core_rst_n),
        .button_n(start_n),
        .pressed(start_pressed),
        .pressed_pulse(start_pulse)
    );

    signal_monitor_core #(
        .SAMPLE_MODE(0),
        .CLK_FREQ_HZ(54000000),
        .BAUD_RATE(115200)
    ) signal_monitor_core_inst (
        .clk(clk_proc),
        .rst_n(core_rst_n),
        .start(start_pulse),
        .uart_tx_pin(uart_tx),
        .led(led),
        .state(),
        .next_state(),
        .sample_index(),
        .process_index(),
        .sample_value(),
        .bram_we_dbg(),
        .bram_addr_dbg(),
        .bram_din_dbg(),
        .bram_dout_dbg(),
        .sum_acc(),
        .sumsq_acc(),
        .sum_out(),
        .mean_out(),
        .rms2_out(),
        .overflow(),
        .tx_valid_dbg(),
        .tx_ready_dbg(),
        .tx_byte_dbg(),
        .done()
    );
endmodule

