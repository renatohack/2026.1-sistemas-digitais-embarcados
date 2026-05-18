`timescale 1ns / 1ps
`default_nettype none

module tp3_demo_vectors (
    input wire [1:0] mode,
    input wire [1:0] op,
    input wire [1:0] case_id,
    output reg [7:0] a,
    output reg [7:0] b,
    output reg [7:0] expected,
    output reg [5:0] expected_flags
);

    localparam MODE_UNSIGNED = 2'b00;
    localparam MODE_SIGNED = 2'b01;
    localparam MODE_FIXED = 2'b10;
    localparam MODE_FLOAT = 2'b11;

    localparam OP_ADD = 2'b00;
    localparam OP_SUB = 2'b01;
    localparam OP_MUL = 2'b10;
    localparam OP_DIV = 2'b11;

    localparam [5:0] F_NONE = 6'b000000;
    localparam [5:0] F_OVF = 6'b000001;
    localparam [5:0] F_UDF = 6'b000010;
    localparam [5:0] F_DIV0 = 6'b000100;
    localparam [5:0] F_OVF_SAT = 6'b001001;
    localparam [5:0] F_UDF_SAT = 6'b001010;
    localparam [5:0] F_UNSUP = 6'b010000;
    localparam [5:0] F_INEXACT = 6'b100000;
    localparam [5:0] F_UDF_INEXACT = 6'b100010;

    always @* begin
        a = 8'd0;
        b = 8'd0;
        expected = 8'd0;
        expected_flags = F_NONE;

        case (mode)
            MODE_UNSIGNED: begin
                case (op)
                    OP_ADD: begin
                        case (case_id)
                            2'd0: begin a = 8'd12; b = 8'd5; expected = 8'd17; expected_flags = F_NONE; end
                            2'd1: begin a = 8'd250; b = 8'd10; expected = 8'd4; expected_flags = F_OVF; end
                            2'd2: begin a = 8'd0; b = 8'd0; expected = 8'd0; expected_flags = F_NONE; end
                            default: begin a = 8'd128; b = 8'd127; expected = 8'd255; expected_flags = F_NONE; end
                        endcase
                    end

                    OP_SUB: begin
                        case (case_id)
                            2'd0: begin a = 8'd12; b = 8'd5; expected = 8'd7; expected_flags = F_NONE; end
                            2'd1: begin a = 8'd5; b = 8'd12; expected = 8'd249; expected_flags = F_UDF; end
                            2'd2: begin a = 8'd0; b = 8'd1; expected = 8'd255; expected_flags = F_UDF; end
                            default: begin a = 8'd255; b = 8'd1; expected = 8'd254; expected_flags = F_NONE; end
                        endcase
                    end

                    OP_MUL: begin
                        case (case_id)
                            2'd0: begin a = 8'd12; b = 8'd5; expected = 8'd60; expected_flags = F_NONE; end
                            2'd1: begin a = 8'd20; b = 8'd20; expected = 8'd144; expected_flags = F_OVF; end
                            2'd2: begin a = 8'd16; b = 8'd16; expected = 8'd0; expected_flags = F_OVF; end
                            default: begin a = 8'd3; b = 8'd4; expected = 8'd12; expected_flags = F_NONE; end
                        endcase
                    end

                    default: begin
                        case (case_id)
                            2'd0: begin a = 8'd20; b = 8'd5; expected = 8'd4; expected_flags = F_NONE; end
                            2'd1: begin a = 8'd7; b = 8'd0; expected = 8'd0; expected_flags = F_DIV0; end
                            2'd2: begin a = 8'd7; b = 8'd2; expected = 8'd3; expected_flags = F_INEXACT; end
                            default: begin a = 8'd255; b = 8'd16; expected = 8'd15; expected_flags = F_INEXACT; end
                        endcase
                    end
                endcase
            end

            MODE_SIGNED: begin
                case (op)
                    OP_ADD: begin
                        case (case_id)
                            2'd0: begin a = 8'd10; b = 8'd5; expected = 8'd15; expected_flags = F_NONE; end
                            2'd1: begin a = 8'd100; b = 8'd40; expected = 8'd140; expected_flags = F_OVF; end
                            2'd2: begin a = 8'hce; b = 8'hb0; expected = 8'd126; expected_flags = F_UDF; end
                            default: begin a = 8'hfb; b = 8'd3; expected = 8'hfe; expected_flags = F_NONE; end
                        endcase
                    end

                    OP_SUB: begin
                        case (case_id)
                            2'd0: begin a = 8'd10; b = 8'd5; expected = 8'd5; expected_flags = F_NONE; end
                            2'd1: begin a = 8'h9c; b = 8'd40; expected = 8'd116; expected_flags = F_UDF; end
                            2'd2: begin a = 8'd100; b = 8'hd8; expected = 8'd140; expected_flags = F_OVF; end
                            default: begin a = 8'd3; b = 8'd5; expected = 8'hfe; expected_flags = F_NONE; end
                        endcase
                    end

                    OP_MUL: begin
                        case (case_id)
                            2'd0: begin a = 8'hfc; b = 8'd6; expected = 8'he8; expected_flags = F_NONE; end
                            2'd1: begin a = 8'd50; b = 8'd5; expected = 8'hfa; expected_flags = F_OVF; end
                            2'd2: begin a = 8'hc4; b = 8'd3; expected = 8'd76; expected_flags = F_UDF; end
                            default: begin a = 8'hf8; b = 8'hf8; expected = 8'd64; expected_flags = F_NONE; end
                        endcase
                    end

                    default: begin
                        case (case_id)
                            2'd0: begin a = 8'hec; b = 8'd5; expected = 8'hfc; expected_flags = F_NONE; end
                            2'd1: begin a = 8'd7; b = 8'd0; expected = 8'd0; expected_flags = F_DIV0; end
                            2'd2: begin a = 8'd7; b = 8'd2; expected = 8'd3; expected_flags = F_INEXACT; end
                            default: begin a = 8'hf9; b = 8'd2; expected = 8'hfd; expected_flags = F_INEXACT; end
                        endcase
                    end
                endcase
            end

            MODE_FIXED: begin
                case (op)
                    OP_ADD: begin
                        case (case_id)
                            2'd0: begin a = 8'd24; b = 8'd8; expected = 8'd32; expected_flags = F_NONE; end
                            2'd1: begin a = 8'd120; b = 8'd16; expected = 8'd127; expected_flags = F_OVF_SAT; end
                            2'd2: begin a = 8'h88; b = 8'hf0; expected = 8'h80; expected_flags = F_UDF_SAT; end
                            default: begin a = 8'd4; b = 8'd1; expected = 8'd5; expected_flags = F_NONE; end
                        endcase
                    end

                    OP_SUB: begin
                        case (case_id)
                            2'd0: begin a = 8'd24; b = 8'd8; expected = 8'd16; expected_flags = F_NONE; end
                            2'd1: begin a = 8'h88; b = 8'd16; expected = 8'h80; expected_flags = F_UDF_SAT; end
                            2'd2: begin a = 8'd120; b = 8'hf0; expected = 8'd127; expected_flags = F_OVF_SAT; end
                            default: begin a = 8'd4; b = 8'd8; expected = 8'hfc; expected_flags = F_NONE; end
                        endcase
                    end

                    OP_MUL: begin
                        case (case_id)
                            2'd0: begin a = 8'd24; b = 8'd8; expected = 8'd12; expected_flags = F_NONE; end
                            2'd1: begin a = 8'd120; b = 8'd32; expected = 8'd127; expected_flags = F_OVF_SAT; end
                            2'd2: begin a = 8'h88; b = 8'd32; expected = 8'h80; expected_flags = F_UDF_SAT; end
                            default: begin a = 8'd5; b = 8'd5; expected = 8'd1; expected_flags = F_INEXACT; end
                        endcase
                    end

                    default: begin
                        case (case_id)
                            2'd0: begin a = 8'd24; b = 8'd8; expected = 8'd48; expected_flags = F_NONE; end
                            2'd1: begin a = 8'd16; b = 8'd0; expected = 8'd0; expected_flags = F_DIV0; end
                            2'd2: begin a = 8'd16; b = 8'd48; expected = 8'd5; expected_flags = F_INEXACT; end
                            default: begin a = 8'h80; b = 8'd8; expected = 8'h80; expected_flags = F_UDF_SAT; end
                        endcase
                    end
                endcase
            end

            default: begin
                case (op)
                    OP_ADD: begin
                        case (case_id)
                            2'd0: begin a = 8'h38; b = 8'h30; expected = 8'h3c; expected_flags = F_NONE; end
                            2'd1: begin a = 8'h77; b = 8'h77; expected = 8'h78; expected_flags = F_OVF; end
                            2'd2: begin a = 8'h38; b = 8'hb8; expected = 8'h00; expected_flags = F_NONE; end
                            default: begin a = 8'h08; b = 8'h89; expected = 8'h00; expected_flags = F_UDF_INEXACT; end
                        endcase
                    end

                    OP_SUB: begin
                        case (case_id)
                            2'd0: begin a = 8'h38; b = 8'h30; expected = 8'h30; expected_flags = F_NONE; end
                            2'd1: begin a = 8'h30; b = 8'h38; expected = 8'hb0; expected_flags = F_NONE; end
                            2'd2: begin a = 8'h77; b = 8'hf7; expected = 8'h78; expected_flags = F_OVF; end
                            default: begin a = 8'h08; b = 8'h09; expected = 8'h00; expected_flags = F_UDF_INEXACT; end
                        endcase
                    end

                    default: begin
                        a = 8'h38;
                        b = 8'h30;
                        expected = 8'd0;
                        expected_flags = F_UNSUP;
                    end
                endcase
            end
        endcase
    end

endmodule

`default_nettype wire
