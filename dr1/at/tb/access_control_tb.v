`timescale 1ns / 1ps

module tb_access_control;
    reg clk;
    reg [3:0] code_btn;
    reg btn_confirm;
    reg btn_reset;

    wire led_authorized;
    wire led_denied;
    wire led_attempt;
    wire [2:0] led_count;

    access_control dut (
        .clk(clk),
        .code_btn(code_btn),
        .btn_confirm(btn_confirm),
        .btn_reset(btn_reset),
        .led_authorized(led_authorized),
        .led_denied(led_denied),
        .led_attempt(led_attempt),
        .led_count(led_count)
    );

    always #5 clk = ~clk;

    task automatic expect_outputs;
        input [8*40-1:0] label;
        input [2:0] expected_count;
        input expected_authorized;
        input expected_denied;
        begin
            if (led_count !== expected_count) begin
                $fatal(1, "FALHA (%0s): contador = %b, esperado = %b, tempo = %0t",
                    label, led_count, expected_count, $time);
            end

            if (led_authorized !== expected_authorized) begin
                $fatal(1, "FALHA (%0s): LED0 = %b, esperado = %b, tempo = %0t",
                    label, led_authorized, expected_authorized, $time);
            end

            if (led_denied !== expected_denied) begin
                $fatal(1, "FALHA (%0s): LED1 = %b, esperado = %b, tempo = %0t",
                    label, led_denied, expected_denied, $time);
            end
        end
    endtask

    task automatic settle_code;
        input [3:0] value;
        begin
            code_btn = value;
            repeat (3) @(posedge clk);
            #1;
        end
    endtask

    task automatic attempt_code;
        input [8*40-1:0] label;
        input [3:0] value;
        input expected_authorized;
        input expected_denied;
        input [2:0] expected_count;
        input integer hold_cycles;
        begin
            settle_code(value);

            btn_confirm = 1'b1;
            repeat (hold_cycles) @(posedge clk);
            #1;

            if (led_attempt !== 1'b1) begin
                $fatal(1, "FALHA (%0s): LED2 deveria indicar tentativa durante BTN1 ativo, tempo = %0t",
                    label, $time);
            end

            btn_confirm = 1'b0;
            repeat (3) @(posedge clk);
            #1;

            if (led_attempt !== 1'b0) begin
                $fatal(1, "FALHA (%0s): LED2 deveria apagar apos a liberacao de BTN1, tempo = %0t",
                    label, $time);
            end

            expect_outputs(label, expected_count, expected_authorized, expected_denied);
        end
    endtask

    task automatic apply_reset;
        input [8*40-1:0] label;
        begin
            btn_reset = 1'b1;
            repeat (3) @(posedge clk);
            #1;

            if ({led_authorized, led_denied, led_attempt, led_count} !== 6'b000000) begin
                $fatal(1, "FALHA (%0s): reset nao limpou imediatamente as saidas esperadas, tempo = %0t",
                    label, $time);
            end

            btn_reset = 1'b0;
            repeat (3) @(posedge clk);
            #1;

            if (led_attempt !== 1'b0) begin
                $fatal(1, "FALHA (%0s): LED2 deveria permanecer apagado apos reset, tempo = %0t",
                    label, $time);
            end

            expect_outputs(label, 3'b000, 1'b0, 1'b0);
        end
    endtask

    initial begin
        $dumpfile("sim/vcd/access_control.vcd");
        $dumpvars(0, tb_access_control);

        clk = 1'b0;
        code_btn = 4'b0000;
        btn_confirm = 1'b0;
        btn_reset = 1'b0;

        repeat (2) @(posedge clk);

        apply_reset("reset_inicial");

        attempt_code("codigo_correto", 4'b1011, 1'b1, 1'b0, 3'b001, 4);
        attempt_code("codigo_incorreto", 4'b0101, 1'b0, 1'b1, 3'b010, 4);
        attempt_code("multiplas_1", 4'b0000, 1'b0, 1'b1, 3'b011, 6);
        attempt_code("multiplas_2", 4'b1011, 1'b1, 1'b0, 3'b100, 4);

        apply_reset("reset_final");

        $display("SIMULACAO_OK");
        $finish;
    end
endmodule
