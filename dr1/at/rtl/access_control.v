`timescale 1ns / 1ps

module access_control (
    input  wire       clk,
    input  wire [3:0] code_btn,
    input  wire       btn_confirm,
    input  wire       btn_reset,
    output reg        led_authorized,
    output reg        led_denied,
    output wire       led_attempt,
    output wire [2:0] led_count
);
    reg [3:0] code_meta;
    reg [3:0] code_sync;

    reg confirm_meta;
    reg confirm_sync;
    reg confirm_sync_d;

    reg reset_meta;
    reg reset_sync;

    reg [2:0] attempt_count;

    wire code_valid;
    wire confirm_pulse;

    code_validator validator (
        .code_in(code_sync),
        .code_valid(code_valid)
    );

    assign confirm_pulse = confirm_sync & ~confirm_sync_d;
    assign led_attempt = ~reset_sync & confirm_sync;
    assign led_count = attempt_count;

    // Sincroniza os botoes externos antes de usá-los na logica interna.
    always @(posedge clk) begin
        code_meta <= code_btn;
        code_sync <= code_meta;

        confirm_meta <= btn_confirm;
        confirm_sync <= confirm_meta;
        confirm_sync_d <= confirm_sync;

        reset_meta <= btn_reset;
        reset_sync <= reset_meta;
    end

    always @(posedge clk) begin
        if (reset_sync) begin
            attempt_count <= 3'b000;
            led_authorized <= 1'b0;
            led_denied <= 1'b0;
        end else if (confirm_pulse) begin
            attempt_count <= attempt_count + 3'b001;
            led_authorized <= code_valid;
            led_denied <= ~code_valid;
        end
    end
endmodule
