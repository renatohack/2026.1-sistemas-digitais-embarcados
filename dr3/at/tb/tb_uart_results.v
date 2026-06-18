`timescale 1ns/1ps

module tb_uart_results;
    localparam integer CLK_FREQ_HZ = 1152000;
    localparam integer BAUD_RATE = 115200;
    localparam integer BIT_CYCLES = CLK_FREQ_HZ / BAUD_RATE;
    localparam integer MSG_LEN = 65;

    reg clk;
    reg rst_n;
    reg start;

    wire uart_tx;
    wire [5:0] led;
    wire [3:0] state;
    wire [3:0] next_state;
    wire [3:0] sample_index;
    wire [3:0] process_index;
    wire signed [15:0] sample_value;
    wire bram_we;
    wire [3:0] bram_addr;
    wire signed [15:0] bram_din;
    wire signed [15:0] bram_dout;
    wire signed [31:0] sum_acc;
    wire [39:0] sumsq_acc;
    wire signed [31:0] sum_out;
    wire signed [31:0] mean_out;
    wire [31:0] rms2_out;
    wire overflow;
    wire tx_valid;
    wire tx_ready;
    wire [7:0] tx_byte;
    wire done;

    reg [7:0] received [0:MSG_LEN-1];
    reg signed [31:0] expected_sum;
    reg [39:0] expected_sumsq;
    reg [31:0] sample_square;
    integer write_count;
    integer i;

    signal_monitor_core #(
        .SAMPLE_SEED(16'hACE1),
        .CLK_FREQ_HZ(CLK_FREQ_HZ),
        .BAUD_RATE(BAUD_RATE)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .start(start),
        .uart_tx_pin(uart_tx),
        .led(led),
        .state(state),
        .next_state(next_state),
        .sample_index(sample_index),
        .process_index(process_index),
        .sample_value(sample_value),
        .bram_we_dbg(bram_we),
        .bram_addr_dbg(bram_addr),
        .bram_din_dbg(bram_din),
        .bram_dout_dbg(bram_dout),
        .sum_acc(sum_acc),
        .sumsq_acc(sumsq_acc),
        .sum_out(sum_out),
        .mean_out(mean_out),
        .rms2_out(rms2_out),
        .overflow(overflow),
        .tx_valid_dbg(tx_valid),
        .tx_ready_dbg(tx_ready),
        .tx_byte_dbg(tx_byte),
        .done(done)
    );

    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            expected_sum <= 32'sd0;
            expected_sumsq <= 40'd0;
            write_count <= 0;
        end else if (bram_we) begin
            sample_square = bram_din * bram_din;
            expected_sum <= expected_sum + {{16{bram_din[15]}}, bram_din};
            expected_sumsq <= expected_sumsq + {8'd0, sample_square};
            write_count <= write_count + 1;
        end
    end

    function [7:0] hex_char;
        input [3:0] nibble;
        begin
            if (nibble < 4'd10)
                hex_char = 8'h30 + {4'd0, nibble};
            else
                hex_char = 8'h41 + {4'd0, nibble - 4'd10};
        end
    endfunction

    function [3:0] hex_nibble;
        input [31:0] value;
        input integer pos;
        begin
            case (pos)
                0: hex_nibble = value[31:28];
                1: hex_nibble = value[27:24];
                2: hex_nibble = value[23:20];
                3: hex_nibble = value[19:16];
                4: hex_nibble = value[15:12];
                5: hex_nibble = value[11:8];
                6: hex_nibble = value[7:4];
                default: hex_nibble = value[3:0];
            endcase
        end
    endfunction

    function [7:0] expected_byte;
        input integer idx;
        reg signed [31:0] expected_mean;
        reg [31:0] expected_rms2;
        begin
            expected_mean = expected_sum / 32'sd16;
            expected_rms2 = expected_sumsq / 40'd16;

            if ((idx >= 18) && (idx <= 25))
                expected_byte = hex_char(hex_nibble(expected_sum, idx - 18));
            else if ((idx >= 34) && (idx <= 41))
                expected_byte = hex_char(hex_nibble(expected_mean, idx - 34));
            else if ((idx >= 50) && (idx <= 57))
                expected_byte = hex_char(hex_nibble(expected_rms2, idx - 50));
            else begin
                case (idx)
                    0: expected_byte = "D";  1: expected_byte = "R";
                    2: expected_byte = "3";  3: expected_byte = "_";
                    4: expected_byte = "A";  5: expected_byte = "T";
                    6: expected_byte = " ";  7: expected_byte = "N";
                    8: expected_byte = "=";  9: expected_byte = "1";
                    10: expected_byte = "6"; 11: expected_byte = " ";
                    12: expected_byte = "S"; 13: expected_byte = "U";
                    14: expected_byte = "M"; 15: expected_byte = "=";
                    16: expected_byte = "0"; 17: expected_byte = "x";
                    26: expected_byte = " "; 27: expected_byte = "M";
                    28: expected_byte = "E"; 29: expected_byte = "A";
                    30: expected_byte = "N"; 31: expected_byte = "=";
                    32: expected_byte = "0"; 33: expected_byte = "x";
                    42: expected_byte = " "; 43: expected_byte = "R";
                    44: expected_byte = "M"; 45: expected_byte = "S";
                    46: expected_byte = "2"; 47: expected_byte = "=";
                    48: expected_byte = "0"; 49: expected_byte = "x";
                    58: expected_byte = " "; 59: expected_byte = "D";
                    60: expected_byte = "O"; 61: expected_byte = "N";
                    62: expected_byte = "E"; 63: expected_byte = 8'h0d;
                    64: expected_byte = 8'h0a;
                    default: expected_byte = 8'h00;
                endcase
            end
        end
    endfunction

    task uart_read_byte;
        output [7:0] data;
        integer bit_index;
        begin
            wait (uart_tx == 1'b1);
            @(negedge uart_tx);
            repeat (BIT_CYCLES + (BIT_CYCLES / 2)) @(posedge clk);
            for (bit_index = 0; bit_index < 8; bit_index = bit_index + 1) begin
                data[bit_index] = uart_tx;
                repeat (BIT_CYCLES) @(posedge clk);
            end
        end
    endtask

    initial begin
        $dumpfile("build/waves/tb_uart_results.vcd");
        $dumpvars(0, tb_uart_results);

        rst_n = 1'b0;
        start = 1'b0;
        repeat (5) @(posedge clk);
        rst_n = 1'b1;
        repeat (5) @(posedge clk);

        start = 1'b1;
        @(posedge clk);
        start = 1'b0;

        for (i = 0; i < MSG_LEN; i = i + 1) begin
            uart_read_byte(received[i]);
            if (received[i] !== expected_byte(i)) begin
                $display("FAIL: UART byte %0d expected 0x%02h got 0x%02h", i, expected_byte(i), received[i]);
                $finish_and_return(1);
            end
        end

        wait (done);
        if (write_count !== 16) begin
            $display("FAIL: expected 16 random samples before UART, got %0d", write_count);
            $finish_and_return(1);
        end

        $display("PASS: UART transmitted metrics derived from random samples");
        $finish;
    end

    initial begin
        #2000000;
        $display("FAIL: timeout in tb_uart_results");
        $finish_and_return(1);
    end
endmodule
