// ============================================================================
// LFSR25000 - Temporizador para escaneo de teclado (versión dual)
// ----------------------------------------------------------------------------
// Usa un contador corto en simulación para acelerar el escaneo.
// Para FPGA, descomentá la línea `//` frente a `define SIMULATION`.
// ============================================================================

`define SIMULATION   // <--- deja esto así para Icarus o GTKWave

module LFSR25000(
    input Clock,
    input Reset,
    output reg Out
);

`ifdef SIMULATION
    // ===================================================
    // MODO SIMULACIÓN: 250 ciclos (100x más rápido)
    // ===================================================
    reg [8:0] counter;
    always @(posedge Clock or negedge Reset) begin
        if (Reset == 0) begin
            Out <= 0;
            counter <= 9'd0;
        end else begin
            if (counter == 9'd249) begin
                Out <= 1;
                counter <= 9'd0;
            end else begin
                Out <= 0;
                counter <= counter + 1'b1;
            end
        end
    end

`else
    // ===================================================
    // MODO FPGA: 25000 ciclos (anti-rebote real)
    // ===================================================
    reg [14:0] LFSR;
    always @(posedge Clock or negedge Reset) begin
        if (Reset == 0) begin
            Out <= 0;
            LFSR <= 15'b111111111111111;
        end else begin
            LFSR[0] <= LFSR[13] ^ LFSR[14];
            LFSR[14:1] <= LFSR[13:0];
            if (LFSR == 15'b001000010001100)
                Out <= 1;
            else
                Out <= 0;
        end
    end
`endif

endmodule
