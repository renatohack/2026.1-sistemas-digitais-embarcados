`timescale 1ns / 1ps

module access_control_tang_nano_9k_top #(
    parameter integer DEBOUNCE_CYCLES = 270000
) (
    input  wire       sys_clk,
    input  wire       btn_confirm_n,
    input  wire       btn_reset_n,
    input  wire [3:0] code_btn,
    output wire [5:0] led
);
    wire btn_confirm;
    wire btn_reset;

    wire btn_confirm_db;
    wire btn_reset_db;

    wire led_authorized;
    wire led_denied;
    wire led_attempt;
    wire [2:0] led_count;

    assign btn_confirm = ~btn_confirm_n;
    assign btn_reset = ~btn_reset_n;

    button_debouncer #(
        .STABLE_CYCLES(DEBOUNCE_CYCLES)
    ) confirm_debouncer (
        .clk(sys_clk),
        .noisy_in(btn_confirm),
        .debounced_out(btn_confirm_db)
    );

    button_debouncer #(
        .STABLE_CYCLES(DEBOUNCE_CYCLES)
    ) reset_debouncer (
        .clk(sys_clk),
        .noisy_in(btn_reset),
        .debounced_out(btn_reset_db)
    );

    access_control access_control_inst (
        .clk(sys_clk),
        .code_btn(code_btn),
        .btn_confirm(btn_confirm_db),
        .btn_reset(btn_reset_db),
        .led_authorized(led_authorized),
        .led_denied(led_denied),
        .led_attempt(led_attempt),
        .led_count(led_count)
    );

    // Os LEDs onboard da Tang Nano 9K sao ativos em nivel baixo.
    assign led[0] = ~led_authorized;
    assign led[1] = ~led_denied;
    assign led[2] = ~led_attempt;
    assign led[3] = ~led_count[0];
    assign led[4] = ~led_count[1];
    assign led[5] = ~led_count[2];
endmodule
