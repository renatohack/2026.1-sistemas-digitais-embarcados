`timescale 1ns/1ps

module hex_result_stream (
    input clk,
    input rst_n,
    input start,
    input signed [31:0] sum_value,
    input signed [31:0] mean_value,
    input [31:0] rms2_value,
    input tx_ready,
    output reg [7:0] tx_data,
    output reg tx_valid,
    output reg busy,
    output reg done
);
    localparam integer MSG_LEN = 65;

    reg [6:0] index;

    function [7:0] hex_char;
        input [3:0] nibble;
        begin
            if (nibble < 4'd10)
                hex_char = 8'h30 + {4'd0, nibble};
            else
                hex_char = 8'h41 + {4'd0, nibble - 4'd10};
        end
    endfunction

    function [3:0] hex_nibble;
        input [31:0] value;
        input [2:0] pos;
        begin
            case (pos)
                3'd0: hex_nibble = value[31:28];
                3'd1: hex_nibble = value[27:24];
                3'd2: hex_nibble = value[23:20];
                3'd3: hex_nibble = value[19:16];
                3'd4: hex_nibble = value[15:12];
                3'd5: hex_nibble = value[11:8];
                3'd6: hex_nibble = value[7:4];
                default: hex_nibble = value[3:0];
            endcase
        end
    endfunction

    function [7:0] byte_at;
        input [6:0] idx;
        begin
            case (idx)
                7'd0:  byte_at = "D";
                7'd1:  byte_at = "R";
                7'd2:  byte_at = "3";
                7'd3:  byte_at = "_";
                7'd4:  byte_at = "A";
                7'd5:  byte_at = "T";
                7'd6:  byte_at = " ";
                7'd7:  byte_at = "N";
                7'd8:  byte_at = "=";
                7'd9:  byte_at = "1";
                7'd10: byte_at = "6";
                7'd11: byte_at = " ";
                7'd12: byte_at = "S";
                7'd13: byte_at = "U";
                7'd14: byte_at = "M";
                7'd15: byte_at = "=";
                7'd16: byte_at = "0";
                7'd17: byte_at = "x";
                7'd18: byte_at = hex_char(hex_nibble(sum_value, 3'd0));
                7'd19: byte_at = hex_char(hex_nibble(sum_value, 3'd1));
                7'd20: byte_at = hex_char(hex_nibble(sum_value, 3'd2));
                7'd21: byte_at = hex_char(hex_nibble(sum_value, 3'd3));
                7'd22: byte_at = hex_char(hex_nibble(sum_value, 3'd4));
                7'd23: byte_at = hex_char(hex_nibble(sum_value, 3'd5));
                7'd24: byte_at = hex_char(hex_nibble(sum_value, 3'd6));
                7'd25: byte_at = hex_char(hex_nibble(sum_value, 3'd7));
                7'd26: byte_at = " ";
                7'd27: byte_at = "M";
                7'd28: byte_at = "E";
                7'd29: byte_at = "A";
                7'd30: byte_at = "N";
                7'd31: byte_at = "=";
                7'd32: byte_at = "0";
                7'd33: byte_at = "x";
                7'd34: byte_at = hex_char(hex_nibble(mean_value, 3'd0));
                7'd35: byte_at = hex_char(hex_nibble(mean_value, 3'd1));
                7'd36: byte_at = hex_char(hex_nibble(mean_value, 3'd2));
                7'd37: byte_at = hex_char(hex_nibble(mean_value, 3'd3));
                7'd38: byte_at = hex_char(hex_nibble(mean_value, 3'd4));
                7'd39: byte_at = hex_char(hex_nibble(mean_value, 3'd5));
                7'd40: byte_at = hex_char(hex_nibble(mean_value, 3'd6));
                7'd41: byte_at = hex_char(hex_nibble(mean_value, 3'd7));
                7'd42: byte_at = " ";
                7'd43: byte_at = "R";
                7'd44: byte_at = "M";
                7'd45: byte_at = "S";
                7'd46: byte_at = "2";
                7'd47: byte_at = "=";
                7'd48: byte_at = "0";
                7'd49: byte_at = "x";
                7'd50: byte_at = hex_char(hex_nibble(rms2_value, 3'd0));
                7'd51: byte_at = hex_char(hex_nibble(rms2_value, 3'd1));
                7'd52: byte_at = hex_char(hex_nibble(rms2_value, 3'd2));
                7'd53: byte_at = hex_char(hex_nibble(rms2_value, 3'd3));
                7'd54: byte_at = hex_char(hex_nibble(rms2_value, 3'd4));
                7'd55: byte_at = hex_char(hex_nibble(rms2_value, 3'd5));
                7'd56: byte_at = hex_char(hex_nibble(rms2_value, 3'd6));
                7'd57: byte_at = hex_char(hex_nibble(rms2_value, 3'd7));
                7'd58: byte_at = " ";
                7'd59: byte_at = "D";
                7'd60: byte_at = "O";
                7'd61: byte_at = "N";
                7'd62: byte_at = "E";
                7'd63: byte_at = 8'h0d;
                7'd64: byte_at = 8'h0a;
                default: byte_at = 8'h00;
            endcase
        end
    endfunction

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            index <= 7'd0;
            tx_data <= 8'd0;
            tx_valid <= 1'b0;
            busy <= 1'b0;
            done <= 1'b0;
        end else begin
            done <= 1'b0;

            if (start && !busy && !tx_valid) begin
                index <= 7'd0;
                tx_data <= byte_at(7'd0);
                tx_valid <= 1'b1;
                busy <= 1'b1;
            end else if (tx_valid && tx_ready) begin
                if (index == MSG_LEN - 1) begin
                    tx_valid <= 1'b0;
                    busy <= 1'b0;
                    done <= 1'b1;
                end else begin
                    index <= index + 7'd1;
                    tx_data <= byte_at(index + 7'd1);
                    tx_valid <= 1'b1;
                    busy <= 1'b1;
                end
            end
        end
    end
endmodule

