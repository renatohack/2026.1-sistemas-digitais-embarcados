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

    task automatic press_code_button;
        input integer index;
        input [8*40-1:0] label;
        input [3:0] expected_code_state;
        begin
            code_btn[index] = 1'b1;
            wait_cycles(6);
            code_btn[index] = 1'b0;
            wait_cycles(6);

            if (dut.code_state !== expected_code_state) begin
                $fatal(1, "FALHA (%0s): code_state = %b, esperado = %b, tempo = %0t",
                    label, dut.code_state, expected_code_state, $time);
            end
        end
    endtask

    task automatic confirm_attempt;
        input [8*40-1:0] label;
        input expected_authorized;
        input expected_denied;
        input [2:0] expected_count;
        begin
            wait_cycles(4);

            btn_confirm_n = 1'b0;
            wait_cycles(8);
            expect_leds({label, "_durante"}, expected_authorized, expected_denied, 1'b1, expected_count);

            btn_confirm_n = 1'b1;
            wait_cycles(8);
            expect_leds(label, expected_authorized, expected_denied, 1'b0, expected_count);
        end
    endtask

    task automatic attempt_code;
        input [8*40-1:0] label;
        input expected_authorized;
        input expected_denied;
        input [2:0] expected_count;
        begin
            confirm_attempt(label, expected_authorized, expected_denied, expected_count);
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

        press_code_button(3, "toggle_bit3_on", 4'b1000);
        press_code_button(1, "toggle_bit1_on", 4'b1010);
        press_code_button(0, "toggle_bit0_on", 4'b1011);
        attempt_code("codigo_correto_fpga", 1'b1, 1'b0, 3'b001);

        press_code_button(0, "toggle_bit0_off", 4'b1010);
        attempt_code("codigo_incorreto_fpga", 1'b0, 1'b1, 3'b010);

        press_code_button(0, "toggle_bit0_on_again", 4'b1011);
        press_code_button(2, "toggle_bit2_on", 4'b1111);
        attempt_code("codigo_incorreto_fpga_2", 1'b0, 1'b1, 3'b011);
        apply_reset("reset_final_fpga");

        if (dut.code_state !== 4'b0000) begin
            $fatal(1, "FALHA (reset_final_fpga): code_state deveria zerar junto com reset, tempo = %0t",
                $time);
        end

        $display("SIMULACAO_FPGA_OK");
        $finish;
    end
endmodule
