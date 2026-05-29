`timescale 1ns/1ps

module tb_signal_monitor_core;
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

    signal_monitor_core #(
        .SAMPLE_MODE(0),
        .CLK_FREQ_HZ(1152000),
        .BAUD_RATE(115200)
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

    initial begin
        $dumpfile("build/waves/tb_signal_monitor_core.vcd");
        $dumpvars(0, tb_signal_monitor_core);

        rst_n = 1'b0;
        start = 1'b0;
        repeat (5) @(posedge clk);
        rst_n = 1'b1;
        repeat (5) @(posedge clk);

        start = 1'b1;
        @(posedge clk);
        start = 1'b0;

        wait (done);
        @(posedge clk);

        if (sum_out !== 32'sd64) begin
            $display("FAIL: expected sum 64, got %0d", sum_out);
            $finish_and_return(1);
        end

        if (mean_out !== 32'sd4) begin
            $display("FAIL: expected mean 4, got %0d", mean_out);
            $finish_and_return(1);
        end

        if (rms2_out !== 32'd368) begin
            $display("FAIL: expected rms2 368, got %0d", rms2_out);
            $finish_and_return(1);
        end

        if (overflow !== 1'b0) begin
            $display("FAIL: unexpected overflow");
            $finish_and_return(1);
        end

        $display("PASS: core typical flow produced SUM=%0d MEAN=%0d RMS2=%0d", sum_out, mean_out, rms2_out);
        $finish;
    end

    initial begin
        #2000000;
        $display("FAIL: timeout in tb_signal_monitor_core");
        $finish_and_return(1);
    end
endmodule
