`timescale 1ns / 1ps

module result_display_mux #(
    parameter SUCCESS_CYCLE_TICKS = 6750000,
    parameter COUNTER_WIDTH = 23
) (
    input wire clk,
    input wire rst_n,
    input wire [3:0] base_value,
    input wire base_error,
    input wire success_active,
    input wire [3:0] success_tens,
    input wire [3:0] success_ones,
    output reg [3:0] display_value,
    output reg display_error,
    output reg display_success,
    output reg [1:0] phase_debug
);

    reg [COUNTER_WIDTH-1:0] tick_count;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            tick_count <= {COUNTER_WIDTH{1'b0}};
            phase_debug <= 2'd0;
        end else if (!success_active) begin
            tick_count <= {COUNTER_WIDTH{1'b0}};
            phase_debug <= 2'd0;
        end else if (tick_count == SUCCESS_CYCLE_TICKS - 1) begin
            tick_count <= {COUNTER_WIDTH{1'b0}};
            if (phase_debug == 2'd2) begin
                phase_debug <= 2'd0;
            end else begin
                phase_debug <= phase_debug + 1'b1;
            end
        end else begin
            tick_count <= tick_count + 1'b1;
        end
    end

    always @* begin
        display_value = base_value;
        display_error = base_error;
        display_success = 1'b0;

        if (success_active) begin
            case (phase_debug)
                2'd0: begin
                    display_value = 4'd0;
                    display_error = 1'b0;
                    display_success = 1'b1;
                end
                2'd1: begin
                    display_value = success_tens;
                    display_error = 1'b0;
                end
                default: begin
                    display_value = success_ones;
                    display_error = 1'b0;
                end
            endcase
        end
    end

endmodule
