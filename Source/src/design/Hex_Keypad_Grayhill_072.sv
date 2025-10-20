`timescale 1ns / 1ps

module Hex_Keypad_Grayhill_072(
    input [3:0] Row,      // entradas del teclado
    input S_Row,          // no usado, opcional
    input clock,
    input reset,
    output reg [3:0] Code, // valor 0–F
    output Valid,          // 1 cuando hay tecla válida
    output reg [3:0] Col   // control de columnas
);

    // ==========================
    // 1. Anti-rebote en filas
    // ==========================
    wire [3:0] Row_clean;

    Debounce db0 (.clk(clock), .n_reset(reset), .button_in(Row[0]), .DB_out(Row_clean[0]));
    Debounce db1 (.clk(clock), .n_reset(reset), .button_in(Row[1]), .DB_out(Row_clean[1]));
    Debounce db2 (.clk(clock), .n_reset(reset), .button_in(Row[2]), .DB_out(Row_clean[2]));
    Debounce db3 (.clk(clock), .n_reset(reset), .button_in(Row[3]), .DB_out(Row_clean[3]));

    // ==========================
    // 2. Lógica de escaneo
    // ==========================
    reg [1:0] scan_state;
    reg [3:0] key_val;
    reg key_valid;

    assign Valid = key_valid;

    always @(posedge clock or negedge reset) begin
        if (!reset) begin
            scan_state <= 2'd0;
            Col <= 4'b1110;
            key_valid <= 1'b0;
            Code <= 4'h0;
        end else begin
            case (scan_state)
                2'd0: begin
                    Col <= 4'b1110; // Columna 0 activa
                    if (Row_clean != 4'b1111) begin
                        key_val <= Row_clean;
                        key_valid <= 1'b1;
                        scan_state <= 2'd1;
                    end
                end
                2'd1: begin
                    Col <= 4'b1101; // Columna 1
                    if (Row_clean != 4'b1111) begin
                        key_val <= Row_clean;
                        key_valid <= 1'b1;
                        scan_state <= 2'd2;
                    end
                end
                2'd2: begin
                    Col <= 4'b1011; // Columna 2
                    if (Row_clean != 4'b1111) begin
                        key_val <= Row_clean;
                        key_valid <= 1'b1;
                        scan_state <= 2'd3;
                    end
                end
                2'd3: begin
                    Col <= 4'b0111; // Columna 3
                    if (Row_clean != 4'b1111) begin
                        key_val <= Row_clean;
                        key_valid <= 1'b1;
                        scan_state <= 2'd0;
                    end
                end
            endcase
        end
    end

    // ==========================
    // 3. Decodificación simple (ejemplo)
    // ==========================
    always @(*) begin
        case ({Col, key_val})
            8'b1110_1110: Code = 4'h1;
            8'b1110_1101: Code = 4'h2;
            8'b1110_1011: Code = 4'h3;
            8'b1110_0111: Code = 4'hA;
            8'b1101_1110: Code = 4'h4;
            8'b1101_1101: Code = 4'h5;
            8'b1101_1011: Code = 4'h6;
            8'b1101_0111: Code = 4'hB;
            8'b1011_1110: Code = 4'h7;
            8'b1011_1101: Code = 4'h8;
            8'b1011_1011: Code = 4'h9;
            8'b1011_0111: Code = 4'hC;
            8'b0111_1110: Code = 4'hE; // '#'
            8'b0111_1101: Code = 4'h0;
            8'b0111_1011: Code = 4'hF; // '*'
            8'b0111_0111: Code = 4'hD;
            default: Code = 4'h0;
        endcase
    end
endmodule
