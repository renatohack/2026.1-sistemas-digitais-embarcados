`timescale 1ns / 1ps

module pll_wrapper #(
    parameter LOCK_DELAY = 4
) (
    input wire clkin,
    input wire reset_n,
    output wire clkout,
    output wire lock
);

`ifdef __ICARUS__
    reg clk_div2;
    reg lock_reg;
    reg [7:0] lock_count;

    assign clkout = clk_div2;
    assign lock = lock_reg;

    initial begin
        clk_div2 = 1'b0;
        lock_reg = 1'b0;
        lock_count = 8'd0;
    end

    always @(posedge clkin or negedge reset_n) begin
        if (!reset_n) begin
            clk_div2 <= 1'b0;
            lock_reg <= 1'b0;
            lock_count <= 8'd0;
        end else begin
            clk_div2 <= ~clk_div2;
            if (!lock_reg) begin
                if (lock_count == LOCK_DELAY - 1) begin
                    lock_reg <= 1'b1;
                end else begin
                    lock_count <= lock_count + 1'b1;
                end
            end
        end
    end
`else
    gowin_rpll_27_to_13p5 pll_inst (
        .clkout(clkout),
        .lock(lock),
        .clkin(clkin)
    );
`endif

endmodule
