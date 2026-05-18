`timescale 1ns / 1ps

module tb_tp3_demo_top;

    localparam UART_CLKS_PER_BIT = 8;
    localparam BIT_TIME_CYCLES = UART_CLKS_PER_BIT;
    localparam MSG_LEN = 79;

    reg sys_clk;
    reg sys_rst_n;
    reg [3:0] btn_n;
    wire [3:0] led_n;
    wire uart_tx;

    reg [7:0] line [0:MSG_LEN-1];
    reg [7:0] rx_byte;
    integer errors;
    integer i;

    tp3_demo_top #(
        .DEBOUNCE_TICKS(2),
        .DEBOUNCE_WIDTH(3),
        .UART_CLKS_PER_BIT(UART_CLKS_PER_BIT),
        .UART_COUNTER_WIDTH(4)
    ) dut (
        .sys_clk(sys_clk),
        .sys_rst_n(sys_rst_n),
        .btn_n(btn_n),
        .led_n(led_n),
        .uart_tx(uart_tx)
    );

    initial begin
        sys_clk = 1'b0;
        forever #5 sys_clk = ~sys_clk;
    end

    initial begin
        $dumpfile("sim/build/tb_tp3_demo_top.vcd");
        $dumpvars(0, tb_tp3_demo_top);

        errors = 0;
        sys_rst_n = 1'b1;
        btn_n = 4'b1111;

        #1;
        sys_rst_n = 1'b0;
        repeat (5) @(posedge sys_clk);
        sys_rst_n = 1'b1;

        read_line;
        check_char(0, "T", "initial line starts with T");
        check_char(1, "P", "initial line starts with P");
        check_char(2, "3", "initial line starts with 3");
        check_char(9, "U", "initial mode is unsigned");
        check_char(19, "A", "initial operation is add");
        check_char(28, "0", "initial case is zero");
        check_char(32, "0", "initial A high hex");
        check_char(33, "C", "initial A low hex");
        check_char(37, "0", "initial B high hex");
        check_char(38, "5", "initial B low hex");
        check_char(47, "1", "initial result high hex");
        check_char(48, "1", "initial result low hex");
        check_char(56, "0", "initial flag high hex");
        check_char(57, "0", "initial flag low hex");
        check_char(59, "O", "initial flag description is OK");
        check_char(74, "Y", "initial PASS is YES");
        check(led_n[0] == 1'b0, "PASS LED is active low");

        wait_uart_idle;
        start_button(0);
        read_line;
        release_button(0);
        check_char(9, "I", "BTN0 changes mode");
        check(led_n[2] == 1'b0, "mode bit 0 LED is active low");

        wait_uart_idle;
        start_button(1);
        read_line;
        release_button(1);
        check_char(19, "S", "BTN1 changes operation");

        wait_uart_idle;
        start_button(2);
        read_line;
        release_button(2);
        check_char(28, "1", "BTN2 changes case id");

        wait_uart_idle;
        start_button(3);
        read_line;
        release_button(3);
        check_char(9, "I", "BTN3 retransmits current mode");
        check_char(19, "S", "BTN3 retransmits current operation");
        check_char(28, "1", "BTN3 retransmits current case id");

        if (errors == 0) begin
            $display("ALL TESTS PASSED");
            $finish;
        end else begin
            $display("TESTS FAILED: %0d error(s)", errors);
            $fatal;
        end
    end

    initial begin
        #2000000;
        $display("FAIL: top simulation timeout");
        $fatal;
    end

    task wait_uart_idle;
        begin
            wait ((dut.sending == 1'b0) && (dut.uart_busy == 1'b0));
            repeat (2) @(posedge sys_clk);
        end
    endtask

    task start_button;
        input integer index;
        begin
            @(negedge sys_clk);
            btn_n[index] = 1'b0;
        end
    endtask

    task release_button;
        input integer index;
        begin
            @(negedge sys_clk);
            btn_n[index] = 1'b1;
            repeat (8) @(posedge sys_clk);
        end
    endtask

    task read_line;
        begin
            for (i = 0; i < MSG_LEN; i = i + 1) begin
                read_uart_byte(rx_byte);
                line[i] = rx_byte;
            end
            $write("UART:");
            for (i = 0; i < MSG_LEN; i = i + 1) begin
                $write("%c", line[i]);
            end
        end
    endtask

    task read_uart_byte;
        output [7:0] value;
        integer bit_i;
        begin
            value = 8'd0;
            @(negedge uart_tx);
            repeat (BIT_TIME_CYCLES + (BIT_TIME_CYCLES / 2)) @(posedge sys_clk);
            for (bit_i = 0; bit_i < 8; bit_i = bit_i + 1) begin
                value[bit_i] = uart_tx;
                repeat (BIT_TIME_CYCLES) @(posedge sys_clk);
            end
        end
    endtask

    task check_char;
        input integer index;
        input [7:0] expected_char;
        input [1023:0] message;
        begin
            if (line[index] !== expected_char) begin
                $display("FAIL: %0s index=%0d got=%c expected=%c", message, index, line[index], expected_char);
                errors = errors + 1;
            end else begin
                $display("PASS: %0s", message);
            end
        end
    endtask

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

endmodule
