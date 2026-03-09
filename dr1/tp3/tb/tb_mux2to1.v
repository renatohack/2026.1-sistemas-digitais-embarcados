`timescale 1ns/1ps

module tb_mux2to1;
    reg D0;
    reg D1;
    reg S;
    wire Y;

    Mux2to1 dut (
        .D0(D0),
        .D1(D1),
        .S(S),
        .Y(Y)
    );

    task apply;
        input tD0;
        input tD1;
        input tS;
        begin
            D0 = tD0;
            D1 = tD1;
            S  = tS;
            #10;
            $display("D0=%0d D1=%0d S=%0d -> Y=%0d", D0, D1, S, Y);
        end
    endtask

    initial begin
        $display("\n==== TB Mux2to1 ====");

        apply(0, 0, 0);
        apply(0, 1, 0);
        apply(1, 0, 0);
        apply(1, 1, 0);

        apply(0, 0, 1);
        apply(0, 1, 1);
        apply(1, 0, 1);
        apply(1, 1, 1);

        $display("==== Fim TB Mux2to1 ====\n");
        $finish;
    end
endmodule
