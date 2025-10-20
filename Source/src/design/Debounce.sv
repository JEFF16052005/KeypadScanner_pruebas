`timescale 1 ns / 100 ps
module Debounce (
    input clk,
    input n_reset,      // activo en bajo
    input button_in,    // señal ruidosa
    output reg DB_out   // salida estable
);
    // Para TangNano 9K con 27 MHz
    // T = [2^(N-1)] / 27e6
    // N=21 → ~39 ms
    parameter N = 21;

    reg [N-1:0] q_reg, q_next;
    reg DFF1, DFF2;
    wire q_add, q_reset;

    assign q_reset = (DFF1 ^ DFF2);
    assign q_add   = ~(q_reg[N-1]);

    always @(*) begin
        case ({q_reset, q_add})
            2'b00: q_next = q_reg;
            2'b01: q_next = q_reg + 1;
            default: q_next = {N{1'b0}};
        endcase
    end

    always @(posedge clk) begin
        if (!n_reset) begin
            DFF1 <= 1'b0;
            DFF2 <= 1'b0;
            q_reg <= {N{1'b0}};
        end else begin
            DFF1 <= button_in;
            DFF2 <= DFF1;
            q_reg <= q_next;
        end
    end

    always @(posedge clk) begin
        if (q_reg[N-1])
            DB_out <= DFF2;
    end
endmodule
