`timescale 1ns/1ps

module signal_monitor_core #(
    parameter SAMPLE_MODE = 0,
    parameter CLK_FREQ_HZ = 54000000,
    parameter BAUD_RATE = 115200
) (
    input clk,
    input rst_n,
    input start,
    output uart_tx_pin,
    output reg [5:0] led,
    output [3:0] state,
    output [3:0] next_state,
    output reg [3:0] sample_index,
    output reg [3:0] process_index,
    output signed [15:0] sample_value,
    output bram_we_dbg,
    output [3:0] bram_addr_dbg,
    output signed [15:0] bram_din_dbg,
    output signed [15:0] bram_dout_dbg,
    output signed [31:0] sum_acc,
    output [39:0] sumsq_acc,
    output signed [31:0] sum_out,
    output signed [31:0] mean_out,
    output [31:0] rms2_out,
    output overflow,
    output tx_valid_dbg,
    output tx_ready_dbg,
    output [7:0] tx_byte_dbg,
    output done
);
    localparam [3:0] STATE_INIT = 4'd0;
    localparam [3:0] STATE_IDLE = 4'd1;
    localparam [3:0] STATE_GENERATE = 4'd2;
    localparam [3:0] STATE_STORE = 4'd3;
    localparam [3:0] STATE_READ = 4'd4;
    localparam [3:0] STATE_PROCESS = 4'd5;
    localparam [3:0] STATE_FORMAT = 4'd6;
    localparam [3:0] STATE_TX = 4'd7;
    localparam [3:0] STATE_DONE = 4'd8;
    localparam [3:0] STATE_ERROR = 4'd9;

    reg [3:0] state_reg;
    reg [3:0] next_state_reg;
    reg bram_we;
    reg [3:0] bram_addr;
    reg signed [15:0] bram_din;
    reg datapath_clear;
    reg datapath_sample_valid;
    reg datapath_finalize;
    reg tx_started;
    reg stream_start;

    wire signed [15:0] bram_dout;
    wire datapath_done;
    wire [4:0] datapath_count;
    wire tx_ready;
    wire [7:0] tx_data;
    wire tx_valid;
    wire stream_busy;
    wire stream_done;

    assign state = state_reg;
    assign next_state = next_state_reg;
    assign bram_we_dbg = bram_we;
    assign bram_addr_dbg = bram_addr;
    assign bram_din_dbg = bram_din;
    assign bram_dout_dbg = bram_dout;
    assign tx_valid_dbg = tx_valid;
    assign tx_ready_dbg = tx_ready;
    assign tx_byte_dbg = tx_data;
    assign done = (state_reg == STATE_DONE);

    sample_generator #(
        .SAMPLE_MODE(SAMPLE_MODE)
    ) sample_generator_inst (
        .index(sample_index),
        .sample(sample_value)
    );

    sample_bram sample_bram_inst (
        .clk(clk),
        .we(bram_we),
        .addr(bram_addr),
        .din(bram_din),
        .dout(bram_dout)
    );

    arithmetic_datapath arithmetic_datapath_inst (
        .clk(clk),
        .rst_n(rst_n),
        .clear(datapath_clear),
        .sample_valid(datapath_sample_valid),
        .finalize(datapath_finalize),
        .sample_in(bram_dout),
        .sum_acc(sum_acc),
        .sumsq_acc(sumsq_acc),
        .sum_out(sum_out),
        .mean_out(mean_out),
        .rms2_out(rms2_out),
        .sample_count(datapath_count),
        .done(datapath_done),
        .overflow(overflow)
    );

    hex_result_stream hex_result_stream_inst (
        .clk(clk),
        .rst_n(rst_n),
        .start(stream_start),
        .sum_value(sum_out),
        .mean_value(mean_out),
        .rms2_value(rms2_out),
        .tx_ready(tx_ready),
        .tx_data(tx_data),
        .tx_valid(tx_valid),
        .busy(stream_busy),
        .done(stream_done)
    );

    uart_tx #(
        .CLK_FREQ_HZ(CLK_FREQ_HZ),
        .BAUD_RATE(BAUD_RATE)
    ) uart_tx_inst (
        .clk(clk),
        .rst_n(rst_n),
        .tx_data(tx_data),
        .tx_data_valid(tx_valid),
        .tx_data_ready(tx_ready),
        .tx_pin(uart_tx_pin)
    );

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            state_reg <= STATE_INIT;
        else
            state_reg <= next_state_reg;
    end

    always @(*) begin
        next_state_reg = state_reg;

        case (state_reg)
            STATE_INIT:
                next_state_reg = STATE_IDLE;
            STATE_IDLE:
                if (start)
                    next_state_reg = STATE_GENERATE;
                else
                    next_state_reg = STATE_IDLE;
            STATE_GENERATE:
                next_state_reg = STATE_STORE;
            STATE_STORE:
                if (sample_index == 4'd15)
                    next_state_reg = STATE_READ;
                else
                    next_state_reg = STATE_GENERATE;
            STATE_READ:
                next_state_reg = STATE_PROCESS;
            STATE_PROCESS:
                if (overflow)
                    next_state_reg = STATE_ERROR;
                else if (process_index == 4'd15)
                    next_state_reg = STATE_FORMAT;
                else
                    next_state_reg = STATE_READ;
            STATE_FORMAT:
                next_state_reg = STATE_TX;
            STATE_TX:
                if (stream_done)
                    next_state_reg = STATE_DONE;
                else
                    next_state_reg = STATE_TX;
            STATE_DONE:
                if (start)
                    next_state_reg = STATE_GENERATE;
                else
                    next_state_reg = STATE_DONE;
            STATE_ERROR:
                if (start)
                    next_state_reg = STATE_GENERATE;
                else
                    next_state_reg = STATE_ERROR;
            default:
                next_state_reg = STATE_ERROR;
        endcase
    end

    always @(*) begin
        bram_we = 1'b0;
        bram_addr = process_index;
        bram_din = sample_value;
        datapath_clear = 1'b0;
        datapath_sample_valid = 1'b0;
        datapath_finalize = 1'b0;
        stream_start = 1'b0;

        case (state_reg)
            STATE_INIT: begin
                datapath_clear = 1'b1;
                bram_addr = 4'd0;
            end
            STATE_IDLE: begin
                datapath_clear = 1'b1;
                bram_addr = 4'd0;
            end
            STATE_GENERATE: begin
                bram_addr = sample_index;
                bram_din = sample_value;
            end
            STATE_STORE: begin
                bram_we = 1'b1;
                bram_addr = sample_index;
                bram_din = sample_value;
            end
            STATE_READ: begin
                bram_addr = process_index;
            end
            STATE_PROCESS: begin
                bram_addr = process_index;
                datapath_sample_valid = 1'b1;
            end
            STATE_FORMAT: begin
                datapath_finalize = 1'b1;
            end
            STATE_TX: begin
                if (!tx_started)
                    stream_start = 1'b1;
            end
            STATE_DONE: begin
                if (start)
                    datapath_clear = 1'b1;
            end
            STATE_ERROR: begin
                if (start)
                    datapath_clear = 1'b1;
            end
            default: begin
                datapath_clear = 1'b1;
            end
        endcase
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            sample_index <= 4'd0;
            process_index <= 4'd0;
            tx_started <= 1'b0;
        end else begin
            case (state_reg)
                STATE_INIT,
                STATE_IDLE: begin
                    sample_index <= 4'd0;
                    process_index <= 4'd0;
                    tx_started <= 1'b0;
                end
                STATE_STORE: begin
                    if (sample_index == 4'd15) begin
                        sample_index <= 4'd0;
                        process_index <= 4'd0;
                    end else begin
                        sample_index <= sample_index + 4'd1;
                    end
                end
                STATE_PROCESS: begin
                    if (process_index != 4'd15)
                        process_index <= process_index + 4'd1;
                end
                STATE_TX: begin
                    if (stream_start)
                        tx_started <= 1'b1;
                end
                STATE_DONE,
                STATE_ERROR: begin
                    if (start) begin
                        sample_index <= 4'd0;
                        process_index <= 4'd0;
                        tx_started <= 1'b0;
                    end
                end
                default: begin
                    sample_index <= sample_index;
                    process_index <= process_index;
                    tx_started <= tx_started;
                end
            endcase
        end
    end

    always @(*) begin
        case (state_reg)
            STATE_IDLE:
                led = 6'b111110;
            STATE_GENERATE,
            STATE_STORE:
                led = 6'b111101;
            STATE_READ,
            STATE_PROCESS,
            STATE_FORMAT:
                led = 6'b111011;
            STATE_TX:
                led = 6'b110111;
            STATE_DONE:
                led = 6'b101111;
            STATE_ERROR:
                led = 6'b011111;
            default:
                led = 6'b111111;
        endcase
    end
endmodule

