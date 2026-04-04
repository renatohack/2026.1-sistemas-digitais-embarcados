`timescale 1ns / 1ps

module tb_access_control_tang_nano_9k_top;
    reg sys_clk;
    reg btn_confirm_n;
    reg btn_reset_n;
    reg [3:0] code_btn;

    wire [5:0] led;

    access_control_tang_nano_9k_top #(
        .DEBOUNCE_CYCLES(2)
    ) dut (
        .sys_clk(sys_clk),
        .btn_confirm_n(btn_confirm_n),
        .btn_reset_n(btn_reset_n),
        .code_btn(code_btn),
        .led(led)
    );

    always #5 sys_clk = ~sys_clk;

    task automatic expect_leds;
        input [8*40-1:0] label;
        input expected_authorized;
        input expected_denied;
        input expected_attempt;
        input [2:0] expected_count;
        begin
            if (led[0] !== ~expected_authorized) begin
                $fatal(1, "FALHA (%0s): LED1 fisico = %b, esperado = %b, tempo = %0t",
                    label, led[0], ~expected_authorized, $time);
            end

            if (led[1] !== ~expected_denied) begin
                $fatal(1, "FALHA (%0s): LED2 fisico = %b, esperado = %b, tempo = %0t",
                    label, led[1], ~expected_denied, $time);
            end

            if (led[2] !== ~expected_attempt) begin
                $fatal(1, "FALHA (%0s): LED3 fisico = %b, esperado = %b, tempo = %0t",
                    label, led[2], ~expected_attempt, $time);
            end

            if (led[3] !== ~expected_count[0]) begin
                $fatal(1, "FALHA (%0s): LED4 fisico = %b, esperado = %b, tempo = %0t",
                    label, led[3], ~expected_count[0], $time);
            end

            if (led[4] !== ~expected_count[1]) begin
                $fatal(1, "FALHA (%0s): LED5 fisico = %b, esperado = %b, tempo = %0t",
                    label, led[4], ~expected_count[1], $time);
            end

            if (led[5] !== ~expected_count[2]) begin
                $fatal(1, "FALHA (%0s): LED6 fisico = %b, esperado = %b, tempo = %0t",
                    label, led[5], ~expected_count[2], $time);
            end
        end
    endtask

    task automatic wait_cycles;
        input integer cycles;
        begin
            repeat (cycles) @(posedge sys_clk);
            #1;
        end
    endtask

    task automatic apply_reset;
        input [8*40-1:0] label;
        begin
            btn_reset_n = 1'b0;
            wait_cycles(8);
            expect_leds(label, 1'b0, 1'b0, 1'b0, 3'b000);

            btn_reset_n = 1'b1;
            wait_cycles(8);
            expect_leds(label, 1'b0, 1'b0, 1'b0, 3'b000);
        end
    endtask

    task automatic attempt_code;
        input [8*40-1:0] label;
        input [3:0] value;
        input expected_authorized;
        input expected_denied;
        input [2:0] expected_count;
        begin
            code_btn = value;
            wait_cycles(3);

            btn_confirm_n = 1'b0;
            wait_cycles(8);
            expect_leds({label, "_durante"}, expected_authorized, expected_denied, 1'b1, expected_count);

            btn_confirm_n = 1'b1;
            wait_cycles(8);
            expect_leds(label, expected_authorized, expected_denied, 1'b0, expected_count);
        end
    endtask

    initial begin
        $dumpfile("sim/vcd/access_control_tang_nano_9k_top.vcd");
        $dumpvars(0, tb_access_control_tang_nano_9k_top);

        sys_clk = 1'b0;
        btn_confirm_n = 1'b1;
        btn_reset_n = 1'b1;
        code_btn = 4'b0000;

        wait_cycles(6);
        apply_reset("reset_inicial_fpga");

        attempt_code("codigo_correto_fpga", 4'b1011, 1'b1, 1'b0, 3'b001);
        attempt_code("codigo_incorreto_fpga", 4'b0101, 1'b0, 1'b1, 3'b010);
        apply_reset("reset_final_fpga");

        $display("SIMULACAO_FPGA_OK");
        $finish;
    end
endmodule
