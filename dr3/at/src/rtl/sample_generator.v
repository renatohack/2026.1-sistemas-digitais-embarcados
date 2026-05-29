`timescale 1ns/1ps

module sample_generator #(
    parameter SAMPLE_MODE = 0
) (
    input  [3:0] index,
    output reg signed [15:0] sample
);
    always @(*) begin
        case (SAMPLE_MODE)
            1: begin
                sample = 16'sd32767;
            end
            2: begin
                sample = 16'sh8000;
            end
            3: begin
                if (index[0])
                    sample = 16'sh8000;
                else
                    sample = 16'sd32767;
            end
            default: begin
                case (index)
                    4'd0:  sample = -16'sd28;
                    4'd1:  sample = -16'sd20;
                    4'd2:  sample = -16'sd12;
                    4'd3:  sample = -16'sd4;
                    4'd4:  sample =  16'sd4;
                    4'd5:  sample =  16'sd12;
                    4'd6:  sample =  16'sd20;
                    4'd7:  sample =  16'sd28;
                    4'd8:  sample =  16'sd36;
                    4'd9:  sample =  16'sd28;
                    4'd10: sample =  16'sd20;
                    4'd11: sample =  16'sd12;
                    4'd12: sample =  16'sd4;
                    4'd13: sample = -16'sd4;
                    4'd14: sample = -16'sd12;
                    4'd15: sample = -16'sd20;
                    default: sample = 16'sd0;
                endcase
            end
        endcase
    end
endmodule
