`timescale 1ns / 1ps

module tb_tp2_sequence_validator;

    localparam STATE_IDLE           = 4'd0;
    localparam STATE_INIT_MEM_WRITE = 4'd1;
    localparam STATE_SHOW_READ      = 4'd2;
    localparam STATE_SHOW_DISPLAY   = 4'd3;
    localparam STATE_WAIT_INPUT     = 4'd4;
    localparam STATE_EXPECT_READ    = 4'd5;
    localparam STATE_CHECK_AND_LOG  = 4'd6;
    localparam STATE_SCORE_CLEAR    = 4'd7;
    localparam STATE_SCORE_READ     = 4'd8;
    localparam STATE_SCORE_ACCUM    = 4'd9;
    localparam STATE_SCORE_STORE    = 4'd10;
    localparam STATE_SUCCESS        = 4'd11;
    localparam STATE_ERROR          = 4'd12;

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
        .SHOW_TICKS(3),
        .SHOW_TICK_WIDTH(4),
        .DEBOUNCE_TICKS(2),
        .DEBOUNCE_WIDTH(2),
        .SUCCESS_CYCLE_TICKS(2),
        .SUCCESS_CYCLE_WIDTH(2)
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
        $dumpfile("sim/build/tb_tp2_sequence_validator.vcd");
        $dumpvars(0, tb_tp2_sequence_validator);

        errors = 0;
        sys_rst_n = 1'b0;
        btn_n = 4'b1111;

        test_pll_and_bram_initialization;
        test_show_sequence_from_bram;
        test_success_path_and_checksum;
        test_error_on_wrong_input;
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
            wait (dut.pll_lock == 1'b1);
            repeat (2) @(posedge dut.core_clk);
        end
    endtask

    task wait_for_state;
        input [3:0] target_state;
        integer timeout;
        begin
            timeout = 0;
            while ((dut.state_debug !== target_state) && (timeout < 400)) begin
                @(posedge dut.core_clk);
                timeout = timeout + 1;
            end
            check(timeout < 400, "state reached before timeout");
        end
    endtask

    task wait_for_success_phase;
        input [1:0] target_phase;
        integer timeout;
        begin
            timeout = 0;
            while ((dut.success_phase_debug !== target_phase) && (timeout < 50)) begin
                @(posedge dut.core_clk);
                timeout = timeout + 1;
            end
            check(timeout < 50, "success display phase reached");
        end
    endtask

    task press_mask;
        input [3:0] mask;
        begin
            btn_n = ~mask;
            repeat (8) @(posedge dut.core_clk);
            btn_n = 4'b1111;
            repeat (8) @(posedge dut.core_clk);
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

    task wait_for_input_phase;
        begin
            wait_for_state(STATE_WAIT_INPUT);
            check(led_n == 4'b1111, "all leds off while waiting for input");
        end
    endtask

    task test_pll_and_bram_initialization;
        begin
            $display("TEST: pll lock gates reset and FSM initializes BRAM");
            sys_rst_n = 1'b0;
            btn_n = 4'b1111;
            repeat (4) @(posedge sys_clk);
            check(dut.pll_lock == 1'b0, "pll unlocked during external reset");
            check(dut.core_rst_n == 1'b0, "core reset stays asserted before lock");
            sys_rst_n = 1'b1;
            wait (dut.pll_lock == 1'b1);
            #1;
            check(dut.core_rst_n == 1'b1, "core reset releases after pll lock");
            wait_for_state(STATE_SHOW_READ);
            check(dut.sync_bram_inst.mem[0] == 16'd0, "bram slot 0 initialized with LED0");
            check(dut.sync_bram_inst.mem[1] == 16'd2, "bram slot 1 initialized with LED2");
            check(dut.sync_bram_inst.mem[2] == 16'd1, "bram slot 2 initialized with LED1");
            check(dut.sync_bram_inst.mem[3] == 16'd3, "bram slot 3 initialized with LED3");
        end
    endtask

    task test_show_sequence_from_bram;
        begin
            $display("TEST: show sequence reads BRAM and lights LEDs in order");
            do_reset;
            wait_for_state(STATE_SHOW_DISPLAY);
            check(led_n == 4'b1110, "show step 1 lights LED0 from BRAM");
            repeat (4) @(posedge dut.core_clk);
            wait_for_state(STATE_SHOW_DISPLAY);
            check(led_n == 4'b1011, "show step 2 lights LED2 from BRAM");
            repeat (4) @(posedge dut.core_clk);
            wait_for_state(STATE_SHOW_DISPLAY);
            check(led_n == 4'b1101, "show step 3 lights LED1 from BRAM");
            repeat (4) @(posedge dut.core_clk);
            wait_for_state(STATE_SHOW_DISPLAY);
            check(led_n == 4'b0111, "show step 4 lights LED3 from BRAM");
            wait_for_input_phase;
        end
    endtask

    task test_success_path_and_checksum;
        begin
            $display("TEST: success path stores input history and computes checksum");
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
            check(dut.sync_bram_inst.mem[4] == 16'd0, "input 0 stored in BRAM");
            check(dut.sync_bram_inst.mem[5] == 16'd2, "input 2 stored in BRAM");
            check(dut.sync_bram_inst.mem[6] == 16'd1, "input 1 stored in BRAM");
            check(dut.sync_bram_inst.mem[7] == 16'd3, "input 3 stored in BRAM");
            check(dut.dsp_mac_inst.acc == 32'd29, "DSP accumulator computed checksum 29");
            check(dut.sync_bram_inst.mem[8] == 16'd29, "checksum stored in BRAM slot 8");
            check(dut.checksum_debug == 8'd29, "checksum latched in FSM");

            wait_for_success_phase(2'd0);
            check({seg_g, seg_f, seg_e, seg_d, seg_c, seg_b, seg_a} == 7'b1101101,
                  "success phase 0 shows S");
            wait_for_success_phase(2'd1);
            check({seg_g, seg_f, seg_e, seg_d, seg_c, seg_b, seg_a} == 7'b1011011,
                  "success phase 1 shows digit 2");
            wait_for_success_phase(2'd2);
            check({seg_g, seg_f, seg_e, seg_d, seg_c, seg_b, seg_a} == 7'b1101111,
                  "success phase 2 shows digit 9");
        end
    endtask

    task test_error_on_wrong_input;
        begin
            $display("TEST: wrong input triggers error");
            do_reset;
            wait_for_input_phase;
            press_button(2'd1);
            wait_for_state(STATE_ERROR);
            check({seg_g, seg_f, seg_e, seg_d, seg_c, seg_b, seg_a} == 7'b1111001,
                  "display shows E on wrong input");
        end
    endtask

    task test_simultaneous_buttons;
        begin
            $display("TEST: simultaneous buttons trigger error");
            do_reset;
            wait_for_input_phase;
            press_mask(4'b0101);
            wait_for_state(STATE_ERROR);
            check({seg_g, seg_f, seg_e, seg_d, seg_c, seg_b, seg_a} == 7'b1111001,
                  "display shows E on simultaneous input");
        end
    endtask

    task test_reset_restarts_after_error;
        begin
            $display("TEST: reset restarts full cycle after error");
            do_reset;
            wait_for_input_phase;
            press_button(2'd1);
            wait_for_state(STATE_ERROR);
            do_reset;
            wait_for_input_phase;
            check(dut.state_debug == STATE_WAIT_INPUT, "reset restarts system after error");
            press_button(2'd0);
            press_button(2'd2);
            press_button(2'd1);
            press_button(2'd3);
            wait_for_state(STATE_SUCCESS);
            check(dut.dsp_mac_inst.acc == 32'd29, "success still works after reset");
        end
    endtask

endmodule
