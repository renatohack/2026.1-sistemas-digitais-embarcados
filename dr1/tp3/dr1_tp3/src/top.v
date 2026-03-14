`timescale 1ns/1ps

// TP3 - Etapa 7
// Top-level para validar fisicamente o contador com:
// - clock onboard de 27 MHz
// - botao onboard para incrementar ao soltar
// - dois LEDs onboard, ativos em nivel baixo
module top (
    input  wire clk,
    input  wire btn_inc_n,
    output wire led0,
    output wire led1
);
    localparam integer DEBOUNCE_CLKS = 270_000;

    reg [18:0] debounce_count = 19'd0;
    reg        btn_sync_0     = 1'b1;
    reg        btn_sync_1     = 1'b1;
    reg        btn_stable     = 1'b1;
    reg        inc_pulse      = 1'b0;
    wire [1:0] count;

    // Sincroniza e faz debounce do botao onboard.
    // O pulso de incremento acontece no momento em que o botao e solto:
    // pressionado = 0, solto = 1.
    always @(posedge clk) begin
        btn_sync_0 <= btn_inc_n;
        btn_sync_1 <= btn_sync_0;
        inc_pulse  <= 1'b0;

        if (btn_sync_1 == btn_stable) begin
            debounce_count <= 19'd0;
        end else if (debounce_count == DEBOUNCE_CLKS - 1) begin
            if ((btn_stable == 1'b0) && (btn_sync_1 == 1'b1))
                inc_pulse <= 1'b1;

            btn_stable     <= btn_sync_1;
            debounce_count <= 19'd0;
        end else begin
            debounce_count <= debounce_count + 1'b1;
        end
    end

    Counter2bit u_counter (
        .clk(inc_pulse),
        .reset(1'b0),
        .Q(count)
    );

    // LEDs onboard da Tang Nano 9K sao ativos em nivel baixo.
    assign led0 = ~count[0];
    assign led1 = ~count[1];

endmodule
