`timescale 1ns / 1ps
`default_nettype none

module tp3_demo_top #(
    parameter DEBOUNCE_TICKS = 270000,
    parameter DEBOUNCE_WIDTH = 19,
    parameter UART_CLKS_PER_BIT = 234,
    parameter UART_COUNTER_WIDTH = 16
) (
    input wire sys_clk,
    input wire sys_rst_n,
    input wire [3:0] btn_n,
    output wire [3:0] led_n,
    output wire uart_tx
);

    localparam MSG_LEN = 7'd79;

    reg [1:0] mode;
    reg [1:0] op;
    reg [1:0] case_id;
    reg [6:0] msg_index;
    reg pending_send;
    reg sending;
    reg uart_start;
    reg [7:0] uart_data;

    wire [3:0] button_pressed;
    wire [3:0] button_pulse;
    wire [7:0] a;
    wire [7:0] b;
    wire [7:0] expected;
    wire [5:0] expected_flags;
    wire [7:0] result;
    wire [5:0] flags;
    wire pass;
    wire uart_busy;
    wire uart_done;

    assign pass = (result == expected) && (flags == expected_flags);
    assign led_n[0] = ~pass;
    assign led_n[1] = ~(|flags);
    assign led_n[2] = ~mode[0];
    assign led_n[3] = ~mode[1];

    genvar button_index;
    generate
        for (button_index = 0; button_index < 4; button_index = button_index + 1) begin : button_inputs
            button_conditioner #(
                .DEBOUNCE_TICKS(DEBOUNCE_TICKS),
                .COUNTER_WIDTH(DEBOUNCE_WIDTH)
            ) button_conditioner_inst (
                .clk(sys_clk),
                .rst_n(sys_rst_n),
                .raw_n(btn_n[button_index]),
                .pressed(button_pressed[button_index]),
                .pressed_pulse(button_pulse[button_index])
            );
        end
    endgenerate

    tp3_demo_vectors tp3_demo_vectors_inst (
        .mode(mode),
        .op(op),
        .case_id(case_id),
        .a(a),
        .b(b),
        .expected(expected),
        .expected_flags(expected_flags)
    );

    arithmetic_core arithmetic_core_inst (
        .mode(mode),
        .op(op),
        .a(a),
        .b(b),
        .result(result),
        .flags(flags)
    );

    uart_tx #(
        .CLKS_PER_BIT(UART_CLKS_PER_BIT),
        .COUNTER_WIDTH(UART_COUNTER_WIDTH)
    ) uart_tx_inst (
        .clk(sys_clk),
        .rst_n(sys_rst_n),
        .start(uart_start),
        .data(uart_data),
        .tx(uart_tx),
        .busy(uart_busy),
        .done(uart_done)
    );

    function [7:0] hex_char;
        input [3:0] value;
        begin
            if (value < 4'd10) begin
                hex_char = 8'h30 + {4'd0, value};
            end else begin
                hex_char = 8'h41 + {4'd0, value - 4'd10};
            end
        end
    endfunction

    function [7:0] mode_char;
        input [2:0] index;
        begin
            case (mode)
                2'd0: begin
                    case (index)
                        3'd0: mode_char = "U";
                        3'd1: mode_char = "I";
                        3'd2: mode_char = "N";
                        3'd3: mode_char = "T";
                        3'd4: mode_char = "8";
                        default: mode_char = " ";
                    endcase
                end

                2'd1: begin
                    case (index)
                        3'd0: mode_char = "I";
                        3'd1: mode_char = "N";
                        3'd2: mode_char = "T";
                        3'd3: mode_char = "8";
                        default: mode_char = " ";
                    endcase
                end

                2'd2: begin
                    case (index)
                        3'd0: mode_char = "Q";
                        3'd1: mode_char = "3";
                        3'd2: mode_char = ".";
                        3'd3: mode_char = "4";
                        default: mode_char = " ";
                    endcase
                end

                default: begin
                    case (index)
                        3'd0: mode_char = "E";
                        3'd1: mode_char = "4";
                        3'd2: mode_char = "M";
                        3'd3: mode_char = "3";
                        default: mode_char = " ";
                    endcase
                end
            endcase
        end
    endfunction

    function [7:0] op_char;
        input [1:0] index;
        begin
            case (op)
                2'd0: begin
                    case (index)
                        2'd0: op_char = "A";
                        2'd1: op_char = "D";
                        default: op_char = "D";
                    endcase
                end

                2'd1: begin
                    case (index)
                        2'd0: op_char = "S";
                        2'd1: op_char = "U";
                        default: op_char = "B";
                    endcase
                end

                2'd2: begin
                    case (index)
                        2'd0: op_char = "M";
                        2'd1: op_char = "U";
                        default: op_char = "L";
                    endcase
                end

                default: begin
                    case (index)
                        2'd0: op_char = "D";
                        2'd1: op_char = "I";
                        default: op_char = "V";
                    endcase
                end
            endcase
        end
    endfunction

    function [7:0] flag_char;
        input [3:0] index;
        begin
            case (flags)
                6'h00: begin
                    case (index)
                        4'd0: flag_char = "O";
                        4'd1: flag_char = "K";
                        default: flag_char = " ";
                    endcase
                end

                6'h01: begin
                    case (index)
                        4'd0: flag_char = "O";
                        4'd1: flag_char = "V";
                        4'd2: flag_char = "E";
                        4'd3: flag_char = "R";
                        4'd4: flag_char = "F";
                        4'd5: flag_char = "L";
                        4'd6: flag_char = "O";
                        4'd7: flag_char = "W";
                        default: flag_char = " ";
                    endcase
                end

                6'h02: begin
                    case (index)
                        4'd0: flag_char = "U";
                        4'd1: flag_char = "N";
                        4'd2: flag_char = "D";
                        4'd3: flag_char = "E";
                        4'd4: flag_char = "R";
                        4'd5: flag_char = "F";
                        4'd6: flag_char = "L";
                        4'd7: flag_char = "O";
                        default: flag_char = "W";
                    endcase
                end

                6'h04: begin
                    case (index)
                        4'd0: flag_char = "D";
                        4'd1: flag_char = "I";
                        4'd2: flag_char = "V";
                        4'd3: flag_char = "_";
                        4'd4: flag_char = "Z";
                        4'd5: flag_char = "E";
                        4'd6: flag_char = "R";
                        4'd7: flag_char = "O";
                        default: flag_char = " ";
                    endcase
                end

                6'h09: begin
                    case (index)
                        4'd0: flag_char = "O";
                        4'd1: flag_char = "V";
                        4'd2: flag_char = "F";
                        4'd3: flag_char = "+";
                        4'd4: flag_char = "S";
                        4'd5: flag_char = "A";
                        4'd6: flag_char = "T";
                        default: flag_char = " ";
                    endcase
                end

                6'h0a: begin
                    case (index)
                        4'd0: flag_char = "U";
                        4'd1: flag_char = "D";
                        4'd2: flag_char = "F";
                        4'd3: flag_char = "+";
                        4'd4: flag_char = "S";
                        4'd5: flag_char = "A";
                        4'd6: flag_char = "T";
                        default: flag_char = " ";
                    endcase
                end

                6'h10: begin
                    case (index)
                        4'd0: flag_char = "U";
                        4'd1: flag_char = "N";
                        4'd2: flag_char = "S";
                        4'd3: flag_char = "U";
                        4'd4: flag_char = "P";
                        default: flag_char = " ";
                    endcase
                end

                6'h20: begin
                    case (index)
                        4'd0: flag_char = "I";
                        4'd1: flag_char = "N";
                        4'd2: flag_char = "E";
                        4'd3: flag_char = "X";
                        4'd4: flag_char = "A";
                        4'd5: flag_char = "C";
                        4'd6: flag_char = "T";
                        default: flag_char = " ";
                    endcase
                end

                6'h22: begin
                    case (index)
                        4'd0: flag_char = "U";
                        4'd1: flag_char = "D";
                        4'd2: flag_char = "F";
                        4'd3: flag_char = "+";
                        4'd4: flag_char = "I";
                        4'd5: flag_char = "N";
                        4'd6: flag_char = "E";
                        4'd7: flag_char = "X";
                        default: flag_char = " ";
                    endcase
                end

                default: begin
                    case (index)
                        4'd0: flag_char = "F";
                        4'd1: flag_char = "L";
                        4'd2: flag_char = "A";
                        4'd3: flag_char = "G";
                        4'd4: flag_char = "S";
                        default: flag_char = " ";
                    endcase
                end
            endcase
        end
    endfunction

    function [7:0] pass_char;
        input [1:0] index;
        begin
            if (pass) begin
                case (index)
                    2'd0: pass_char = "Y";
                    2'd1: pass_char = "E";
                    default: pass_char = "S";
                endcase
            end else begin
                case (index)
                    2'd0: pass_char = "N";
                    2'd1: pass_char = "O";
                    default: pass_char = " ";
                endcase
            end
        end
    endfunction

    function [7:0] message_byte;
        input [6:0] index;
        begin
            case (index)
                6'd0: message_byte = "T";
                6'd1: message_byte = "P";
                6'd2: message_byte = "3";
                6'd3: message_byte = " ";
                6'd4: message_byte = "m";
                6'd5: message_byte = "o";
                6'd6: message_byte = "d";
                6'd7: message_byte = "e";
                6'd8: message_byte = "=";
                6'd9: message_byte = mode_char(3'd0);
                6'd10: message_byte = mode_char(3'd1);
                6'd11: message_byte = mode_char(3'd2);
                6'd12: message_byte = mode_char(3'd3);
                6'd13: message_byte = mode_char(3'd4);
                6'd14: message_byte = mode_char(3'd5);
                6'd15: message_byte = " ";
                6'd16: message_byte = "o";
                6'd17: message_byte = "p";
                6'd18: message_byte = "=";
                6'd19: message_byte = op_char(2'd0);
                6'd20: message_byte = op_char(2'd1);
                6'd21: message_byte = op_char(2'd2);
                6'd22: message_byte = " ";
                6'd23: message_byte = "c";
                6'd24: message_byte = "a";
                6'd25: message_byte = "s";
                6'd26: message_byte = "e";
                6'd27: message_byte = "=";
                6'd28: message_byte = hex_char({2'b00, case_id});
                6'd29: message_byte = " ";
                6'd30: message_byte = "A";
                6'd31: message_byte = "=";
                6'd32: message_byte = hex_char(a[7:4]);
                6'd33: message_byte = hex_char(a[3:0]);
                6'd34: message_byte = " ";
                6'd35: message_byte = "B";
                6'd36: message_byte = "=";
                6'd37: message_byte = hex_char(b[7:4]);
                6'd38: message_byte = hex_char(b[3:0]);
                6'd39: message_byte = " ";
                6'd40: message_byte = "r";
                6'd41: message_byte = "e";
                6'd42: message_byte = "s";
                6'd43: message_byte = "u";
                6'd44: message_byte = "l";
                6'd45: message_byte = "t";
                6'd46: message_byte = "=";
                6'd47: message_byte = hex_char(result[7:4]);
                6'd48: message_byte = hex_char(result[3:0]);
                6'd49: message_byte = " ";
                6'd50: message_byte = "f";
                6'd51: message_byte = "l";
                6'd52: message_byte = "a";
                6'd53: message_byte = "g";
                6'd54: message_byte = "s";
                6'd55: message_byte = "=";
                6'd56: message_byte = hex_char({2'b00, flags[5:4]});
                6'd57: message_byte = hex_char(flags[3:0]);
                6'd58: message_byte = " ";
                6'd59: message_byte = flag_char(4'd0);
                6'd60: message_byte = flag_char(4'd1);
                6'd61: message_byte = flag_char(4'd2);
                6'd62: message_byte = flag_char(4'd3);
                6'd63: message_byte = flag_char(4'd4);
                7'd64: message_byte = flag_char(4'd5);
                7'd65: message_byte = flag_char(4'd6);
                7'd66: message_byte = flag_char(4'd7);
                7'd67: message_byte = flag_char(4'd8);
                7'd68: message_byte = " ";
                7'd69: message_byte = "p";
                7'd70: message_byte = "a";
                7'd71: message_byte = "s";
                7'd72: message_byte = "s";
                7'd73: message_byte = "=";
                7'd74: message_byte = pass_char(2'd0);
                7'd75: message_byte = pass_char(2'd1);
                7'd76: message_byte = pass_char(2'd2);
                7'd77: message_byte = 8'h0d;
                7'd78: message_byte = 8'h0a;
                default: message_byte = 8'h20;
            endcase
        end
    endfunction

    always @(posedge sys_clk or negedge sys_rst_n) begin
        if (!sys_rst_n) begin
            mode <= 2'd0;
            op <= 2'd0;
            case_id <= 2'd0;
            msg_index <= 7'd0;
            pending_send <= 1'b1;
            sending <= 1'b0;
            uart_start <= 1'b0;
            uart_data <= 8'd0;
        end else begin
            uart_start <= 1'b0;

            if (button_pulse[0]) begin
                mode <= mode + 2'd1;
                pending_send <= 1'b1;
            end

            if (button_pulse[1]) begin
                op <= op + 2'd1;
                pending_send <= 1'b1;
            end

            if (button_pulse[2]) begin
                case_id <= case_id + 2'd1;
                pending_send <= 1'b1;
            end

            if (button_pulse[3]) begin
                pending_send <= 1'b1;
            end

            if (!sending && pending_send && !uart_busy) begin
                sending <= 1'b1;
                pending_send <= 1'b0;
                msg_index <= 7'd0;
                uart_data <= message_byte(7'd0);
                uart_start <= 1'b1;
            end else if (sending && uart_done) begin
                if (msg_index == MSG_LEN - 7'd1) begin
                    sending <= 1'b0;
                    msg_index <= 7'd0;
                end else begin
                    msg_index <= msg_index + 7'd1;
                    uart_data <= message_byte(msg_index + 7'd1);
                    uart_start <= 1'b1;
                end
            end
        end
    end

endmodule

`default_nettype wire
