`timescale 1ns / 1ps

module sequence_fsm #(
    parameter SHOW_TICKS = 13500000,
    parameter SHOW_TICK_WIDTH = 24,
    parameter BRAM_ADDR_WIDTH = 4,
    parameter BRAM_DATA_WIDTH = 16,
    parameter DSP_INPUT_WIDTH = 16,
    parameter DSP_ACC_WIDTH = 32
) (
    input wire clk,
    input wire rst_n,
    input wire [3:0] button_pulse,
    input wire [BRAM_DATA_WIDTH-1:0] bram_dout,
    input wire [DSP_ACC_WIDTH-1:0] dsp_acc,
    output reg [3:0] led_n,
    output reg [3:0] display_value,
    output reg display_error,
    output reg success_active,
    output reg [3:0] success_tens,
    output reg [3:0] success_ones,
    output reg bram_en,
    output reg bram_we,
    output reg [BRAM_ADDR_WIDTH-1:0] bram_addr,
    output reg [BRAM_DATA_WIDTH-1:0] bram_din,
    output reg dsp_clear,
    output reg dsp_valid,
    output reg [DSP_INPUT_WIDTH-1:0] dsp_a,
    output reg [DSP_INPUT_WIDTH-1:0] dsp_b,
    output wire [3:0] state_debug,
    output wire [1:0] step_debug,
    output wire [7:0] checksum_debug
);

    localparam STATE_IDLE           = 4'd0;
    localparam STATE_INIT_MEM_WRITE = 4'd1;
    localparam STATE_SHOW_READ      = 4'd2;
    localparam STATE_SHOW_DISPLAY   = 4'd3;
    localparam STATE_WAIT_INPUT     = 4'd4;
    localparam STATE_EXPECT_READ    = 4'd5;
    localparam STATE_CHECK_AND_LOG  = 4'd6;
    localparam STATE_SCORE_CLEAR    = 4'd7;
    localparam STATE_SCORE_READ     = 4'd8;
    localparam STATE_SCORE_ACCUM    = 4'd9;
    localparam STATE_SCORE_STORE    = 4'd10;
    localparam STATE_SUCCESS        = 4'd11;
    localparam STATE_ERROR          = 4'd12;

    localparam ADDR_EXPECTED_BASE = 4'd0;
    localparam ADDR_INPUT_BASE    = 4'd4;
    localparam ADDR_CHECKSUM      = 4'd8;

    reg [3:0] state;
    reg [3:0] next_state;
    reg [1:0] init_index;
    reg [1:0] next_init_index;
    reg [1:0] show_index;
    reg [1:0] next_show_index;
    reg [1:0] input_index;
    reg [1:0] next_input_index;
    reg [1:0] score_index;
    reg [1:0] next_score_index;
    reg [1:0] captured_button;
    reg [1:0] next_captured_button;
    reg [7:0] checksum_value;
    reg [7:0] next_checksum_value;
    reg [SHOW_TICK_WIDTH-1:0] show_tick_count;
    reg [SHOW_TICK_WIDTH-1:0] next_show_tick_count;

    assign state_debug = state;
    assign step_debug = input_index;
    assign checksum_debug = checksum_value;

    function [1:0] sequence_at;
        input [1:0] index;
        begin
            case (index)
                2'd0: sequence_at = 2'd0;
                2'd1: sequence_at = 2'd2;
                2'd2: sequence_at = 2'd1;
                default: sequence_at = 2'd3;
            endcase
        end
    endfunction

    function is_onehot;
        input [3:0] value;
        begin
            case (value)
                4'b0001,
                4'b0010,
                4'b0100,
                4'b1000: is_onehot = 1'b1;
                default: is_onehot = 1'b0;
            endcase
        end
    endfunction

    function [1:0] pulse_to_index;
        input [3:0] value;
        begin
            case (value)
                4'b0001: pulse_to_index = 2'd0;
                4'b0010: pulse_to_index = 2'd1;
                4'b0100: pulse_to_index = 2'd2;
                default: pulse_to_index = 2'd3;
            endcase
        end
    endfunction

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= STATE_IDLE;
            init_index <= 2'd0;
            show_index <= 2'd0;
            input_index <= 2'd0;
            score_index <= 2'd0;
            captured_button <= 2'd0;
            checksum_value <= 8'd0;
            show_tick_count <= {SHOW_TICK_WIDTH{1'b0}};
        end else begin
            state <= next_state;
            init_index <= next_init_index;
            show_index <= next_show_index;
            input_index <= next_input_index;
            score_index <= next_score_index;
            captured_button <= next_captured_button;
            checksum_value <= next_checksum_value;
            show_tick_count <= next_show_tick_count;
        end
    end

    always @* begin
        next_state = state;
        next_init_index = init_index;
        next_show_index = show_index;
        next_input_index = input_index;
        next_score_index = score_index;
        next_captured_button = captured_button;
        next_checksum_value = checksum_value;
        next_show_tick_count = show_tick_count;

        case (state)
            STATE_IDLE: begin
                next_state = STATE_INIT_MEM_WRITE;
                next_init_index = 2'd0;
                next_show_index = 2'd0;
                next_input_index = 2'd0;
                next_score_index = 2'd0;
                next_captured_button = 2'd0;
                next_checksum_value = 8'd0;
                next_show_tick_count = {SHOW_TICK_WIDTH{1'b0}};
            end

            STATE_INIT_MEM_WRITE: begin
                if (init_index == 2'd3) begin
                    next_state = STATE_SHOW_READ;
                    next_init_index = 2'd0;
                    next_show_index = 2'd0;
                end else begin
                    next_init_index = init_index + 1'b1;
                end
            end

            STATE_SHOW_READ: begin
                next_state = STATE_SHOW_DISPLAY;
                next_show_tick_count = {SHOW_TICK_WIDTH{1'b0}};
            end

            STATE_SHOW_DISPLAY: begin
                if (show_tick_count == SHOW_TICKS - 1) begin
                    next_show_tick_count = {SHOW_TICK_WIDTH{1'b0}};
                    if (show_index == 2'd3) begin
                        next_state = STATE_WAIT_INPUT;
                        next_show_index = 2'd0;
                        next_input_index = 2'd0;
                    end else begin
                        next_show_index = show_index + 1'b1;
                        next_state = STATE_SHOW_READ;
                    end
                end else begin
                    next_show_tick_count = show_tick_count + 1'b1;
                end
            end

            STATE_WAIT_INPUT: begin
                if (button_pulse != 4'b0000) begin
                    if (!is_onehot(button_pulse)) begin
                        next_state = STATE_ERROR;
                    end else begin
                        next_captured_button = pulse_to_index(button_pulse);
                        next_state = STATE_EXPECT_READ;
                    end
                end
            end

            STATE_EXPECT_READ: begin
                next_state = STATE_CHECK_AND_LOG;
            end

            STATE_CHECK_AND_LOG: begin
                if (captured_button == bram_dout[1:0]) begin
                    if (input_index == 2'd3) begin
                        next_state = STATE_SCORE_CLEAR;
                        next_score_index = 2'd0;
                    end else begin
                        next_input_index = input_index + 1'b1;
                        next_state = STATE_WAIT_INPUT;
                    end
                end else begin
                    next_state = STATE_ERROR;
                end
            end

            STATE_SCORE_CLEAR: begin
                next_state = STATE_SCORE_READ;
                next_score_index = 2'd0;
            end

            STATE_SCORE_READ: begin
                next_state = STATE_SCORE_ACCUM;
            end

            STATE_SCORE_ACCUM: begin
                if (score_index == 2'd3) begin
                    next_state = STATE_SCORE_STORE;
                end else begin
                    next_score_index = score_index + 1'b1;
                    next_state = STATE_SCORE_READ;
                end
            end

            STATE_SCORE_STORE: begin
                next_checksum_value = dsp_acc[7:0];
                next_state = STATE_SUCCESS;
            end

            STATE_SUCCESS: begin
                next_state = STATE_SUCCESS;
            end

            STATE_ERROR: begin
                next_state = STATE_ERROR;
            end

            default: begin
                next_state = STATE_IDLE;
                next_init_index = 2'd0;
                next_show_index = 2'd0;
                next_input_index = 2'd0;
                next_score_index = 2'd0;
                next_captured_button = 2'd0;
                next_checksum_value = 8'd0;
                next_show_tick_count = {SHOW_TICK_WIDTH{1'b0}};
            end
        endcase
    end

    always @* begin
        led_n = 4'b1111;
        display_value = 4'd0;
        display_error = 1'b0;
        success_active = 1'b0;
        success_tens = checksum_value / 8'd10;
        success_ones = checksum_value % 8'd10;

        bram_en = 1'b0;
        bram_we = 1'b0;
        bram_addr = {BRAM_ADDR_WIDTH{1'b0}};
        bram_din = {BRAM_DATA_WIDTH{1'b0}};

        dsp_clear = 1'b0;
        dsp_valid = 1'b0;
        dsp_a = {DSP_INPUT_WIDTH{1'b0}};
        dsp_b = {DSP_INPUT_WIDTH{1'b0}};

        case (state)
            STATE_INIT_MEM_WRITE: begin
                bram_en = 1'b1;
                bram_we = 1'b1;
                bram_addr = ADDR_EXPECTED_BASE + init_index;
                bram_din = {{(BRAM_DATA_WIDTH-2){1'b0}}, sequence_at(init_index)};
            end

            STATE_SHOW_READ: begin
                bram_en = 1'b1;
                bram_addr = ADDR_EXPECTED_BASE + show_index;
            end

            STATE_SHOW_DISPLAY: begin
                led_n[bram_dout[1:0]] = 1'b0;
                display_value = {2'b00, show_index} + 4'd1;
            end

            STATE_WAIT_INPUT: begin
                display_value = {2'b00, input_index};
            end

            STATE_EXPECT_READ: begin
                bram_en = 1'b1;
                bram_addr = ADDR_EXPECTED_BASE + input_index;
                display_value = {2'b00, input_index};
            end

            STATE_CHECK_AND_LOG: begin
                display_value = {2'b00, input_index};
                if (captured_button == bram_dout[1:0]) begin
                    bram_en = 1'b1;
                    bram_we = 1'b1;
                    bram_addr = ADDR_INPUT_BASE + input_index;
                    bram_din = {{(BRAM_DATA_WIDTH-2){1'b0}}, captured_button};
                end else begin
                    display_error = 1'b1;
                end
            end

            STATE_SCORE_CLEAR: begin
                display_value = 4'd4;
                dsp_clear = 1'b1;
            end

            STATE_SCORE_READ: begin
                display_value = 4'd4;
                bram_en = 1'b1;
                bram_addr = ADDR_INPUT_BASE + score_index;
            end

            STATE_SCORE_ACCUM: begin
                display_value = 4'd4;
                dsp_valid = 1'b1;
                dsp_a = {{(DSP_INPUT_WIDTH-2){1'b0}}, bram_dout[1:0]} +
                        {{(DSP_INPUT_WIDTH-1){1'b0}}, 1'b1};
                dsp_b = {{(DSP_INPUT_WIDTH-2){1'b0}}, score_index} +
                        {{(DSP_INPUT_WIDTH-1){1'b0}}, 1'b1};
            end

            STATE_SCORE_STORE: begin
                bram_en = 1'b1;
                bram_we = 1'b1;
                bram_addr = ADDR_CHECKSUM;
                bram_din = dsp_acc[BRAM_DATA_WIDTH-1:0];
                success_active = 1'b1;
            end

            STATE_SUCCESS: begin
                success_active = 1'b1;
            end

            STATE_ERROR: begin
                display_error = 1'b1;
            end

            default: begin
                display_value = 4'd0;
            end
        endcase
    end

endmodule
