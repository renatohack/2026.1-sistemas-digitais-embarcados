module Top (
    input  wire i_Switch_1,
    input  wire i_Switch_2,
    input  wire i_Switch_3,
    input  wire i_Switch_4,
    output wire o_LED_1,
    output wire o_LED_2,
    output wire o_LED_3,
    output wire o_LED_4
);

    wire logic_f;

    Logic_Block u_logic_block (
        .A(i_Switch_1),
        .B(i_Switch_2),
        .C(i_Switch_3),
        .F(logic_f)
    );

    assign o_LED_1 = logic_f;
    assign o_LED_2 = i_Switch_2;
    assign o_LED_3 = i_Switch_3;
    assign o_LED_4 = i_Switch_4;

endmodule
