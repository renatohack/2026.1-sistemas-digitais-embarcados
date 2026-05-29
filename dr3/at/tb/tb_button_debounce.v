`timescale 1ns/1ps

module tb_button_debounce;
    reg clk;
    reg rst_n;
    reg button_n;
    wire pressed;
    wire pressed_pulse;

    integer pulse_count;

    button_debounce #(
        .DEBOUNCE_CYCLES(4)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .button_n(button_n),
        .pressed(pressed),
        .pressed_pulse(pressed_pulse)
    );

    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    always @(posedge clk) begin
        if (pressed_pulse)
            pulse_count = pulse_count + 1;
    end

    initial begin
        $dumpfile("build/waves/tb_button_debounce.vcd");
        $dumpvars(0, tb_button_debounce);

        pulse_count = 0;
        rst_n = 1'b0;
        button_n = 1'b1;
        repeat (4) @(posedge clk);
        rst_n = 1'b1;

        button_n = 1'b0;
        @(posedge clk);
        button_n = 1'b1;
        @(posedge clk);
        button_n = 1'b0;
        @(posedge clk);
        button_n = 1'b1;
        @(posedge clk);

        button_n = 1'b0;
        repeat (10) @(posedge clk);
        button_n = 1'b1;
        repeat (10) @(posedge clk);

        if (pulse_count !== 1) begin
            $display("FAIL: expected one debounced pulse, got %0d", pulse_count);
            $finish_and_return(1);
        end

        $display("PASS: debounce generated one start pulse");
        $finish;
    end
endmodule
