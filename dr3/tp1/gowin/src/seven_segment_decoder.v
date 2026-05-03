`timescale 1ns / 1ps

module seven_segment_decoder (
    input wire [3:0] value,
    input wire error,
    input wire success,
    output reg [6:0] seg
);

    /*
     * Common cathode display, active-high outputs.
     * Bit order: seg[0]=A, seg[1]=B, seg[2]=C, seg[3]=D,
     * seg[4]=E, seg[5]=F, seg[6]=G.
     */
    always @* begin
        if (error) begin
            seg = 7'b1111001;      // E
        end else if (success) begin
            seg = 7'b1101101;      // S
        end else begin
            case (value)
                4'd0: seg = 7'b0111111;
                4'd1: seg = 7'b0000110;
                4'd2: seg = 7'b1011011;
                4'd3: seg = 7'b1001111;
                4'd4: seg = 7'b1100110;
                default: seg = 7'b0000000;
            endcase
        end
    end

endmodule
