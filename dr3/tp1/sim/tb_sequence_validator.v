`timescale 1ns / 1ps

module tb_sequence_validator;

    localparam STATE_IDLE       = 3'd0;
    localparam STATE_SHOW       = 3'd1;
    localparam STATE_WAIT_INPUT = 3'd2;
    localparam STATE_ERROR      = 3'd3;
    localparam STATE_SUCCESS    = 3'd4;

    reg sys_clk;
    reg sys_rst_n;
    reg [3:0] btn_n;
    wire [3:0] led_n;
    wire seg_a;
    wire seg_b;
    wire seg_c;
    wire seg_d;
    wire seg_e;
    wire seg_f;
    wire seg_g;

    integer errors;

    sequence_validator_top #(
        .DISPLAY_TICKS(4),
        .TICK_WIDTH(4),
        .DEBOUNCE_TICKS(2),
        .DEBOUNCE_WIDTH(2)
    ) dut (
        .sys_clk(sys_clk),
        .sys_rst_n(sys_rst_n),
        .btn_n(btn_n),
        .led_n(led_n),
        .seg_a(seg_a),
        .seg_b(seg_b),
        .seg_c(seg_c),
        .seg_d(seg_d),
        .seg_e(seg_e),
        .seg_f(seg_f),
        .seg_g(seg_g)
    );

    initial begin
        sys_clk = 1'b0;
        forever #5 sys_clk = ~sys_clk;
    end

    initial begin
        $dumpfile("sim/build/tb_sequence_validator.vcd");
        $dumpvars(0, tb_sequence_validator);

        errors = 0;
        sys_rst_n = 1'b0;
        btn_n = 4'b1111;

        test_show_sequence;
        test_success_path;
        test_error_on_first_input;
        test_error_in_middle;
        test_simultaneous_buttons;
        test_reset_restarts_after_error;

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

    task do_reset;
        begin
            btn_n = 4'b1111;
            sys_rst_n = 1'b0;
            repeat (4) @(posedge sys_clk);
            sys_rst_n = 1'b1;
            repeat (2) @(posedge sys_clk);
        end
    endtask

    task wait_for_state;
        input [2:0] target_state;
        integer timeout;
        begin
            timeout = 0;
            while ((dut.state_debug !== target_state) && (timeout < 200)) begin
                @(posedge sys_clk);
                timeout = timeout + 1;
            end
            check(timeout < 200, "state reached before timeout");
        end
    endtask

    task wait_for_input_phase;
        begin
            wait_for_state(STATE_WAIT_INPUT);
            check(led_n == 4'b1111, "all leds off while waiting for input");
        end
    endtask

    task press_mask;
        input [3:0] mask;
        begin
            btn_n = ~mask;
            repeat (8) @(posedge sys_clk);
            btn_n = 4'b1111;
            repeat (8) @(posedge sys_clk);
        end
    endtask

    task press_button;
        input [1:0] index;
        begin
            case (index)
                2'd0: press_mask(4'b0001);
                2'd1: press_mask(4'b0010);
                2'd2: press_mask(4'b0100);
                default: press_mask(4'b1000);
            endcase
        end
    endtask

    task test_show_sequence;
        begin
            $display("TEST: show sequence LED0, LED2, LED1, LED3");
            do_reset;
            wait_for_state(STATE_SHOW);
            check(led_n == 4'b1110, "show step 1 lights LED0");
            repeat (4) @(posedge sys_clk);
            check(led_n == 4'b1011, "show step 2 lights LED2");
            repeat (4) @(posedge sys_clk);
            check(led_n == 4'b1101, "show step 3 lights LED1");
            repeat (4) @(posedge sys_clk);
            check(led_n == 4'b0111, "show step 4 lights LED3");
            wait_for_input_phase;
        end
    endtask

    task test_success_path;
        begin
            $display("TEST: success path 0,2,1,3");
            do_reset;
            wait_for_input_phase;
            press_button(2'd0);
            check(dut.step_debug == 2'd1, "first correct input advances progress");
            press_button(2'd2);
            check(dut.step_debug == 2'd2, "second correct input advances progress");
            press_button(2'd1);
            check(dut.step_debug == 2'd3, "third correct input advances progress");
            press_button(2'd3);
            wait_for_state(STATE_SUCCESS);
            check(dut.display_success == 1'b1, "success display flag is active");
            check({seg_g, seg_f, seg_e, seg_d, seg_c, seg_b, seg_a} == 7'b1101101,
                  "seven segment shows S on success");
            repeat (10) @(posedge sys_clk);
            check(dut.state_debug == STATE_SUCCESS, "success state is latched until reset");
        end
    endtask

    task test_error_on_first_input;
        begin
            $display("TEST: error on first input");
            do_reset;
            wait_for_input_phase;
            press_button(2'd1);
            wait_for_state(STATE_ERROR);
            check(dut.display_error == 1'b1, "error display flag is active");
            check({seg_g, seg_f, seg_e, seg_d, seg_c, seg_b, seg_a} == 7'b1111001,
                  "seven segment shows E on error");
            repeat (10) @(posedge sys_clk);
            check(dut.state_debug == STATE_ERROR, "error state is latched until reset");
        end
    endtask

    task test_error_in_middle;
        begin
            $display("TEST: error after partial correct sequence");
            do_reset;
            wait_for_input_phase;
            press_button(2'd0);
            check(dut.step_debug == 2'd1, "partial sequence accepted first input");
            press_button(2'd3);
            wait_for_state(STATE_ERROR);
            check(dut.display_error == 1'b1, "wrong middle input triggers error");
        end
    endtask

    task test_simultaneous_buttons;
        begin
            $display("TEST: simultaneous buttons trigger error");
            do_reset;
            wait_for_input_phase;
            press_mask(4'b0101);
            wait_for_state(STATE_ERROR);
            check(dut.display_error == 1'b1, "multiple simultaneous inputs trigger error");
        end
    endtask

    task test_reset_restarts_after_error;
        begin
            $display("TEST: reset restarts after error");
            do_reset;
            wait_for_input_phase;
            press_button(2'd1);
            wait_for_state(STATE_ERROR);
            do_reset;
            wait_for_input_phase;
            check(dut.state_debug == STATE_WAIT_INPUT, "reset restarts cycle after error");
            press_button(2'd0);
            press_button(2'd2);
            press_button(2'd1);
            press_button(2'd3);
            wait_for_state(STATE_SUCCESS);
            check(dut.display_success == 1'b1, "success works after reset");
        end
    endtask

endmodule
