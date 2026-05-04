`timescale 1ns / 1ps

module tb_sync_bram;

    reg clk;
    reg en;
    reg we;
    reg [3:0] addr;
    reg [15:0] din;
    wire [15:0] dout;
    integer errors;

    sync_bram dut (
        .clk(clk),
        .en(en),
        .we(we),
        .addr(addr),
        .din(din),
        .dout(dout)
    );

    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    initial begin
        $dumpfile("sim/build/tb_sync_bram.vcd");
        $dumpvars(0, tb_sync_bram);

        errors = 0;
        en = 1'b0;
        we = 1'b0;
        addr = 4'd0;
        din = 16'd0;

        write_word(4'd0, 16'd1);
        write_word(4'd1, 16'd2);
        write_word(4'd8, 16'd29);

        read_word(4'd0, 16'd1, "read expected sequence slot 0");
        read_word(4'd1, 16'd2, "read expected sequence slot 1");
        read_word(4'd8, 16'd29, "read checksum slot");

        write_word(4'd1, 16'd7);
        read_word(4'd1, 16'd7, "overwrite existing slot");

        if (errors == 0) begin
            $display("ALL TESTS PASSED");
            $finish;
        end else begin
            $display("TESTS FAILED: %0d error(s)", errors);
            $fatal;
        end
    end

    task check;
        input condition;
        input [1023:0] message;
        begin
            if (!condition) begin
                $display("FAIL: %0s", message);
                errors = errors + 1;
            end else begin
                $display("PASS: %0s", message);
            end
        end
    endtask

    task write_word;
        input [3:0] write_addr;
        input [15:0] write_data;
        begin
            @(negedge clk);
            en = 1'b1;
            we = 1'b1;
            addr = write_addr;
            din = write_data;
            @(posedge clk);
            @(negedge clk);
            en = 1'b0;
            we = 1'b0;
            addr = 4'd0;
            din = 16'd0;
        end
    endtask

    task read_word;
        input [3:0] read_addr;
        input [15:0] expected_data;
        input [1023:0] message;
        begin
            @(negedge clk);
            en = 1'b1;
            we = 1'b0;
            addr = read_addr;
            @(posedge clk);
            #1;
            check(dout == expected_data, message);
            @(negedge clk);
            en = 1'b0;
            addr = 4'd0;
        end
    endtask

endmodule
