`timescale 1ns/1ps

module Top_tb;

    reg i_Switch_1;
    reg i_Switch_2;
    reg i_Switch_3;
    reg i_Switch_4;

    wire o_LED_1;
    wire o_LED_2;
    wire o_LED_3;
    wire o_LED_4;

    Top dut (
        .i_Switch_1(i_Switch_1),
        .i_Switch_2(i_Switch_2),
        .i_Switch_3(i_Switch_3),
        .i_Switch_4(i_Switch_4),
        .o_LED_1(o_LED_1),
        .o_LED_2(o_LED_2),
        .o_LED_3(o_LED_3),
        .o_LED_4(o_LED_4)
    );

    initial begin
        $display("t(ns) SW1 SW2 SW3 SW4 | LED1 LED2 LED3 LED4");

        // 1) 0 0 0 0
        {i_Switch_1, i_Switch_2, i_Switch_3, i_Switch_4} = 4'b0000;
        #10;
        $display("%4t   %b   %b   %b   %b  |   %b    %b    %b    %b",
                 $time, i_Switch_1, i_Switch_2, i_Switch_3, i_Switch_4,
                 o_LED_1, o_LED_2, o_LED_3, o_LED_4);

        // 2) 0 1 0 1
        {i_Switch_1, i_Switch_2, i_Switch_3, i_Switch_4} = 4'b0101;
        #10;
        $display("%4t   %b   %b   %b   %b  |   %b    %b    %b    %b",
                 $time, i_Switch_1, i_Switch_2, i_Switch_3, i_Switch_4,
                 o_LED_1, o_LED_2, o_LED_3, o_LED_4);

        // 3) 1 0 1 0
        {i_Switch_1, i_Switch_2, i_Switch_3, i_Switch_4} = 4'b1010;
        #10;
        $display("%4t   %b   %b   %b   %b  |   %b    %b    %b    %b",
                 $time, i_Switch_1, i_Switch_2, i_Switch_3, i_Switch_4,
                 o_LED_1, o_LED_2, o_LED_3, o_LED_4);

        // 4) 1 1 0 0
        {i_Switch_1, i_Switch_2, i_Switch_3, i_Switch_4} = 4'b1100;
        #10;
        $display("%4t   %b   %b   %b   %b  |   %b    %b    %b    %b",
                 $time, i_Switch_1, i_Switch_2, i_Switch_3, i_Switch_4,
                 o_LED_1, o_LED_2, o_LED_3, o_LED_4);

        // 5) 1 1 1 0
        {i_Switch_1, i_Switch_2, i_Switch_3, i_Switch_4} = 4'b1110;
        #10;
        $display("%4t   %b   %b   %b   %b  |   %b    %b    %b    %b",
                 $time, i_Switch_1, i_Switch_2, i_Switch_3, i_Switch_4,
                 o_LED_1, o_LED_2, o_LED_3, o_LED_4);

        // 6) 1 0 0 1
        {i_Switch_1, i_Switch_2, i_Switch_3, i_Switch_4} = 4'b1001;
        #10;
        $display("%4t   %b   %b   %b   %b  |   %b    %b    %b    %b",
                 $time, i_Switch_1, i_Switch_2, i_Switch_3, i_Switch_4,
                 o_LED_1, o_LED_2, o_LED_3, o_LED_4);

        #10;
        $finish;
    end

endmodule
