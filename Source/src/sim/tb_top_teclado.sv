`timescale 1ns/1ns
`define SIMULATION

// ============================================================================
// Testbench para top_teclado
// ----------------------------------------------------------------------------
// - Sincroniza cada tecla con la columna activa del escáner
// - Verifica el ingreso de los números 123*456#
// - Muestra las columnas activas (Col) y los resultados de la FSM
// ============================================================================

module tb_top_teclado;

    // Señales globales
    reg clk;
    reg reset_n;
    reg [3:0] Row;
    wire [3:0] Col;
    wire [9:0] Num1, Num2;
    wire Sum_ready;

    // Instancia del sistema completo
    top_teclado dut (
        .clk_27MHz(clk),
        .reset_button(reset_n),
        .Row(Row),
        .Col(Col),
        .Num1(Num1),
        .Num2(Num2),
        .Sum_ready(Sum_ready)
    );

    // ==========================
    // 27 MHz → periodo ~37 ns
    // ==========================
    always #18.5 clk = ~clk;

    // ==========================
    // Inicialización general
    // ==========================
    initial begin
        $dumpfile("tb_top_teclado.vcd");
        $dumpvars(0, tb_top_teclado);
        clk = 0;
        reset_n = 0;
        Row = 4'b1111;
        #100000;
        reset_n = 1;
        #100000;

        $display("\n=== Simulación del sistema completo ===");
        $display("Ingreso: 123*456#\n");

        $display(">>> reset_n = %b", reset_n);
        #500000;
        $display(">>> Col durante reset = %b", Col);

        // =====================
        // Secuencia de ingreso
        // =====================
        press_key(3,0);  // 1
        press_key(2,0);  // 2
        press_key(1,0);  // 3
        press_key(0,3);  // * (confirma Num1)

        press_key(3,1);  // 4
        press_key(2,1);  // 5
        press_key(1,1);  // 6
        press_key(2,3);  // # (confirma Num2)

        #500000;
        $display("\n=== RESULTADOS ===");
        $display("Num1 = %0d", Num1);
        $display("Num2 = %0d", Num2);
        $display("Sum_ready = %b", Sum_ready);
        if (Sum_ready)
            $display("Suma = %0d", Num1 + Num2);

        #200000;
        $finish;
    end

    // ==========================
    // Task: presionar tecla sincronizada
    // ==========================
   task press_key(input integer col, input integer row);
    reg [3:0] row_mask;
    reg [3:0] col_mask;
    integer timeout;
        begin
            // Determinar fila activa (solo 1 bit en bajo)
            case(row)
                0: row_mask = 4'b1110;
                1: row_mask = 4'b1101;
                2: row_mask = 4'b1011;
                3: row_mask = 4'b0111;
            endcase

            // Determinar la columna esperada (solo 1 bit en bajo)
            case(col)
                0: col_mask = 4'b1110;
                1: col_mask = 4'b1101;
                2: col_mask = 4'b1011;
                3: col_mask = 4'b0111;
            endcase

            $display("[%0t] Presionando tecla col=%0d row=%0d", $time, col, row);

            // Esperar con timeout a que el escáner active la columna correcta
            timeout = 0;
            while (Col !== col_mask && timeout < 100000) begin
                #100;
                timeout = timeout + 1;
            end

            if (timeout >= 100000) begin
                $display("[%0t] ⚠️  No se encontró la columna esperada (%b), Col actual=%b",
                        $time, col_mask, Col);
            end

            // Pequeño retardo de estabilidad
            #2000;

            // Presionar fila (poner en bajo)
            Row = row_mask;
            #30000;

            // Liberar tecla
            Row = 4'b1111;
            #30000;
        end
    endtask


    // ==========================
    // Monitorización
    // ==========================
    always @(Col) begin
        $display("[%0t] Col = %b", $time, Col);
    end

endmodule
