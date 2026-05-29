`timescale 1ns/1ps

module uart_tx #(
    parameter CLK_FREQ_HZ = 54000000,
    parameter BAUD_RATE = 115200
) (
    input clk,
    input rst_n,
    input [7:0] tx_data,
    input tx_data_valid,
    output reg tx_data_ready,
    output tx_pin
);
    localparam integer CYCLE = CLK_FREQ_HZ / BAUD_RATE;
    localparam [2:0] S_IDLE = 3'd0;
    localparam [2:0] S_START = 3'd1;
    localparam [2:0] S_SEND_BYTE = 3'd2;
    localparam [2:0] S_STOP = 3'd3;

    reg [2:0] state;
    reg [2:0] next_state;
    reg [15:0] cycle_cnt;
    reg [2:0] bit_cnt;
    reg [7:0] tx_data_latch;
    reg tx_reg;

    assign tx_pin = tx_reg;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            state <= S_IDLE;
        else
            state <= next_state;
    end

    always @(*) begin
        case (state)
            S_IDLE:
                if (tx_data_valid)
                    next_state = S_START;
                else
                    next_state = S_IDLE;
            S_START:
                if (cycle_cnt == CYCLE - 1)
                    next_state = S_SEND_BYTE;
                else
                    next_state = S_START;
            S_SEND_BYTE:
                if ((cycle_cnt == CYCLE - 1) && (bit_cnt == 3'd7))
                    next_state = S_STOP;
                else
                    next_state = S_SEND_BYTE;
            S_STOP:
                if (cycle_cnt == CYCLE - 1)
                    next_state = S_IDLE;
                else
                    next_state = S_STOP;
            default:
                next_state = S_IDLE;
        endcase
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            tx_data_ready <= 1'b0;
        else if (state == S_IDLE) begin
            if (tx_data_valid)
                tx_data_ready <= 1'b0;
            else
                tx_data_ready <= 1'b1;
        end else if ((state == S_STOP) && (cycle_cnt == CYCLE - 1)) begin
            tx_data_ready <= 1'b1;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            tx_data_latch <= 8'd0;
        else if ((state == S_IDLE) && tx_data_valid)
            tx_data_latch <= tx_data;
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            bit_cnt <= 3'd0;
        else if (state == S_SEND_BYTE) begin
            if (cycle_cnt == CYCLE - 1)
                bit_cnt <= bit_cnt + 3'd1;
        end else begin
            bit_cnt <= 3'd0;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            cycle_cnt <= 16'd0;
        else if (((state == S_SEND_BYTE) && (cycle_cnt == CYCLE - 1)) || (next_state != state))
            cycle_cnt <= 16'd0;
        else
            cycle_cnt <= cycle_cnt + 16'd1;
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            tx_reg <= 1'b1;
        else begin
            case (state)
                S_IDLE,
                S_STOP:
                    tx_reg <= 1'b1;
                S_START:
                    tx_reg <= 1'b0;
                S_SEND_BYTE:
                    tx_reg <= tx_data_latch[bit_cnt];
                default:
                    tx_reg <= 1'b1;
            endcase
        end
    end
endmodule

