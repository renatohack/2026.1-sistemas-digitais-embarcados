`timescale 1ns/1ps

module pll_54mhz (
    input clkin,
    input reset,
    output clkout,
    output lock
);
`ifdef SIM
    reg clkout_reg;
    reg lock_reg;

    assign clkout = clkout_reg;
    assign lock = lock_reg;

    initial begin
        clkout_reg = 1'b0;
        lock_reg = 1'b0;
        #120 lock_reg = 1'b1;
    end

    always #9 clkout_reg = ~clkout_reg;

    always @(posedge reset) begin
        lock_reg <= 1'b0;
        #120 lock_reg <= 1'b1;
    end
`else
    wire clkoutp_o;
    wire clkoutd_o;
    wire clkoutd3_o;
    wire gw_gnd;

    assign gw_gnd = 1'b0;

    rPLL rpll_inst (
        .CLKOUT(clkout),
        .LOCK(lock),
        .CLKOUTP(clkoutp_o),
        .CLKOUTD(clkoutd_o),
        .CLKOUTD3(clkoutd3_o),
        .RESET(reset),
        .RESET_P(gw_gnd),
        .CLKIN(clkin),
        .CLKFB(gw_gnd),
        .FBDSEL({gw_gnd, gw_gnd, gw_gnd, gw_gnd, gw_gnd, gw_gnd}),
        .IDSEL({gw_gnd, gw_gnd, gw_gnd, gw_gnd, gw_gnd, gw_gnd}),
        .ODSEL({gw_gnd, gw_gnd, gw_gnd, gw_gnd, gw_gnd, gw_gnd}),
        .PSDA({gw_gnd, gw_gnd, gw_gnd, gw_gnd}),
        .DUTYDA({gw_gnd, gw_gnd, gw_gnd, gw_gnd}),
        .FDLY({gw_gnd, gw_gnd, gw_gnd, gw_gnd})
    );

    defparam rpll_inst.FCLKIN = "27";
    defparam rpll_inst.DYN_IDIV_SEL = "false";
    defparam rpll_inst.IDIV_SEL = 0;
    defparam rpll_inst.DYN_FBDIV_SEL = "false";
    defparam rpll_inst.FBDIV_SEL = 1;
    defparam rpll_inst.DYN_ODIV_SEL = "false";
    defparam rpll_inst.ODIV_SEL = 16;
    defparam rpll_inst.PSDA_SEL = "0000";
    defparam rpll_inst.DYN_DA_EN = "true";
    defparam rpll_inst.DUTYDA_SEL = "1000";
    defparam rpll_inst.CLKOUT_FT_DIR = 1'b1;
    defparam rpll_inst.CLKOUTP_FT_DIR = 1'b1;
    defparam rpll_inst.CLKOUT_DLY_STEP = 0;
    defparam rpll_inst.CLKOUTP_DLY_STEP = 0;
    defparam rpll_inst.CLKFB_SEL = "internal";
    defparam rpll_inst.CLKOUT_BYPASS = "false";
    defparam rpll_inst.CLKOUTP_BYPASS = "false";
    defparam rpll_inst.CLKOUTD_BYPASS = "false";
    defparam rpll_inst.DYN_SDIV_SEL = 2;
    defparam rpll_inst.CLKOUTD_SRC = "CLKOUT";
    defparam rpll_inst.CLKOUTD3_SRC = "CLKOUT";
    defparam rpll_inst.DEVICE = "GW1NR-9C";
`endif
endmodule

