`timescale 1ns / 1ps

module sequence_fsm #(
    parameter DISPLAY_TICKS = 27000000,
    parameter TICK_WIDTH = 25
) (
    input wire clk,
    input wire rst_n,
    input wire [3:0] button_pulse,
    output reg [3:0] led_n,
    output reg [3:0] display_value,
    output reg display_error,
    output reg display_success,
    output wire [2:0] state_debug,
    output wire [1:0] step_debug
);

    localparam STATE_IDLE       = 3'd0;
    localparam STATE_SHOW       = 3'd1;
    localparam STATE_WAIT_INPUT = 3'd2;
    localparam STATE_ERROR      = 3'd3;
    localparam STATE_SUCCESS    = 3'd4;

    reg [2:0] state;
    reg [2:0] next_state;
    reg [1:0] show_index;
    reg [1:0] next_show_index;
    reg [1:0] input_index;
    reg [1:0] next_input_index;
    reg [TICK_WIDTH-1:0] tick_count;
    reg [TICK_WIDTH-1:0] next_tick_count;

    assign state_debug = state;
    assign step_debug = (state == STATE_WAIT_INPUT) ? input_index : show_index;

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
            show_index <= 2'd0;
            input_index <= 2'd0;
            tick_count <= {TICK_WIDTH{1'b0}};
        end else begin
            state <= next_state;
            show_index <= next_show_index;
            input_index <= next_input_index;
            tick_count <= next_tick_count;
        end
    end

    always @* begin
        next_state = state;
        next_show_index = show_index;
        next_input_index = input_index;
        next_tick_count = tick_count;

        case (state)
            STATE_IDLE: begin
                next_state = STATE_SHOW;
                next_show_index = 2'd0;
                next_input_index = 2'd0;
                next_tick_count = {TICK_WIDTH{1'b0}};
            end

            STATE_SHOW: begin
                if (tick_count == DISPLAY_TICKS - 1) begin
                    next_tick_count = {TICK_WIDTH{1'b0}};
                    if (show_index == 2'd3) begin
                        next_state = STATE_WAIT_INPUT;
                        next_show_index = 2'd0;
                        next_input_index = 2'd0;
                    end else begin
                        next_show_index = show_index + 1'b1;
                    end
                end else begin
                    next_tick_count = tick_count + 1'b1;
                end
            end

            STATE_WAIT_INPUT: begin
                if (button_pulse != 4'b0000) begin
                    if (!is_onehot(button_pulse)) begin
                        next_state = STATE_ERROR;
                    end else if (pulse_to_index(button_pulse) == sequence_at(input_index)) begin
                        if (input_index == 2'd3) begin
                            next_state = STATE_SUCCESS;
                        end else begin
                            next_input_index = input_index + 1'b1;
                        end
                    end else begin
                        next_state = STATE_ERROR;
                    end
                end
            end

            STATE_ERROR: begin
                next_state = STATE_ERROR;
            end

            STATE_SUCCESS: begin
                next_state = STATE_SUCCESS;
            end

            default: begin
                next_state = STATE_IDLE;
                next_show_index = 2'd0;
                next_input_index = 2'd0;
                next_tick_count = {TICK_WIDTH{1'b0}};
            end
        endcase
    end

    always @* begin
        led_n = 4'b1111;
        display_value = 4'd0;
        display_error = 1'b0;
        display_success = 1'b0;

        case (state)
            STATE_IDLE: begin
                display_value = 4'd0;
            end

            STATE_SHOW: begin
                led_n[sequence_at(show_index)] = 1'b0;
                display_value = {2'b00, show_index} + 4'd1;
            end

            STATE_WAIT_INPUT: begin
                display_value = {2'b00, input_index};
            end

            STATE_ERROR: begin
                display_error = 1'b1;
            end

            STATE_SUCCESS: begin
                display_success = 1'b1;
                display_value = 4'd4;
            end

            default: begin
                display_value = 4'd0;
            end
        endcase
    end

endmodule
