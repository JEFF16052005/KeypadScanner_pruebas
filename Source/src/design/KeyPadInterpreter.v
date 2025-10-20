`timescale 1ns / 1ps

module KeyPadInterpreter(
    input Clock,
    input Reset_n,
    input [3:0] Code,
    input Valid,
    input KeyRead,       // pulso desde mod_lecturaTeclado
    output reg [3:0] KeyData,
    output reg KeyReady
);
    always @(posedge Clock or negedge Reset_n) begin
        if (!Reset_n) begin
            KeyData <= 4'h0;
            KeyReady <= 1'b0;
        end else begin
            if (Valid) begin
                KeyData <= Code;
                KeyReady <= 1'b1;
            end else if (KeyRead) begin
                KeyReady <= 1'b0; // limpiar cuando mod_lectura lo lea
            end
        end
    end
endmodule
