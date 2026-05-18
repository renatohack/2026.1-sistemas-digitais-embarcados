`timescale 1ns / 1ps
`default_nettype none

module uart_tx #(
    parameter CLKS_PER_BIT = 234,
    parameter COUNTER_WIDTH = 16
) (
    input wire clk,
    input wire rst_n,
    input wire start,
    input wire [7:0] data,
    output reg tx,
    output reg busy,
    output reg done
);

    localparam STATE_IDLE = 2'd0;
    localparam STATE_START = 2'd1;
    localparam STATE_DATA = 2'd2;
    localparam STATE_STOP = 2'd3;

    localparam [COUNTER_WIDTH-1:0] BIT_LIMIT = CLKS_PER_BIT - 1;

    reg [1:0] state;
    reg [2:0] bit_index;
    reg [7:0] shifter;
    reg [COUNTER_WIDTH-1:0] counter;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            tx <= 1'b1;
            busy <= 1'b0;
            done <= 1'b0;
            state <= STATE_IDLE;
            bit_index <= 3'd0;
            shifter <= 8'd0;
            counter <= {COUNTER_WIDTH{1'b0}};
        end else begin
            done <= 1'b0;

            case (state)
                STATE_IDLE: begin
                    tx <= 1'b1;
                    busy <= 1'b0;
                    counter <= {COUNTER_WIDTH{1'b0}};
                    bit_index <= 3'd0;
                    if (start) begin
                        busy <= 1'b1;
                        shifter <= data;
                        tx <= 1'b0;
                        state <= STATE_START;
                    end
                end

                STATE_START: begin
                    busy <= 1'b1;
                    tx <= 1'b0;
                    if (counter == BIT_LIMIT) begin
                        counter <= {COUNTER_WIDTH{1'b0}};
                        tx <= shifter[0];
                        state <= STATE_DATA;
                    end else begin
                        counter <= counter + {{(COUNTER_WIDTH-1){1'b0}}, 1'b1};
                    end
                end

                STATE_DATA: begin
                    busy <= 1'b1;
                    if (counter == BIT_LIMIT) begin
                        counter <= {COUNTER_WIDTH{1'b0}};
                        if (bit_index == 3'd7) begin
                            tx <= 1'b1;
                            state <= STATE_STOP;
                        end else begin
                            bit_index <= bit_index + 3'd1;
                            shifter <= {1'b0, shifter[7:1]};
                            tx <= shifter[1];
                        end
                    end else begin
                        counter <= counter + {{(COUNTER_WIDTH-1){1'b0}}, 1'b1};
                    end
                end

                STATE_STOP: begin
                    busy <= 1'b1;
                    tx <= 1'b1;
                    if (counter == BIT_LIMIT) begin
                        counter <= {COUNTER_WIDTH{1'b0}};
                        busy <= 1'b0;
                        done <= 1'b1;
                        state <= STATE_IDLE;
                    end else begin
                        counter <= counter + {{(COUNTER_WIDTH-1){1'b0}}, 1'b1};
                    end
                end

                default: begin
                    state <= STATE_IDLE;
                    tx <= 1'b1;
                    busy <= 1'b0;
                end
            endcase
        end
    end

endmodule

`default_nettype wire
