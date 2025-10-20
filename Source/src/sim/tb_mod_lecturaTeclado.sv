`timescale 1ns/1ns

module tb_mod_lecturaTeclado;

    // Entradas
    reg Clock;
    reg Reset_n;
    reg [3:0] KeyData;
    reg KeyReady;

    // Salidas
    wire KeyRead;
    wire [9:0] Num1_value;
    wire [9:0] Num2_value;
    wire Num1_done;
    wire Num2_done;
    wire Sum_ready;
    wire [3:0] disp_hundreds, disp_tens, disp_units;
    wire [1:0] active_field;

    // DUT (Device Under Test)
    mod_lecturaTeclado DUT (
        .Clock(Clock),
        .Reset_n(Reset_n),
        .KeyData(KeyData),
        .KeyReady(KeyReady),
        .KeyRead(KeyRead),
        .Num1_value(Num1_value),
        .Num2_value(Num2_value),
        .Num1_done(Num1_done),
        .Num2_done(Num2_done),
        .Sum_ready(Sum_ready),
        .disp_hundreds(disp_hundreds),
        .disp_tens(disp_tens),
        .disp_units(disp_units),
        .active_field(active_field)
    );

    // Generador de reloj (27 MHz ≈ 37 ns periodo)
    always #18.5 Clock = ~Clock;

    // Tarea para simular una tecla
    task press_key;
        input [3:0] code;
        begin
            KeyData = code;
            KeyReady = 1'b1;
            #40;          // tecla presionada durante ~40 ns
            KeyReady = 1'b0;
            #60;          // tiempo entre teclas
        end
    endtask

    // Secuencia de simulación
    initial begin
        $display("==== INICIO DE SIMULACIÓN ====");
        Clock = 0;
        Reset_n = 0;
        KeyData = 0;
        KeyReady = 0;
        #100;
        Reset_n = 1;
        #100;

        // Ingreso de primer número: 123
        press_key(4'h1);
        press_key(4'h2);
        press_key(4'h3);
        press_key(4'hF); // '*' confirma Num1

        // Ingreso de segundo número: 456
        press_key(4'h4);
        press_key(4'h5);
        press_key(4'h6);
        press_key(4'hE); // '#' confirma Num2

        #200;

        // Resultados
        $display("Num1 = %d (done=%b)", Num1_value, Num1_done);
        $display("Num2 = %d (done=%b)", Num2_value, Num2_done);
        $display("Sum_ready = %b", Sum_ready);

        #200;
        $display("==== FIN DE SIMULACIÓN ====");
        $stop;
    end

    initial begin
        $dumpfile("tb_mod_lecturaTeclado.vcd");
        $dumpvars(0, tb_mod_lecturaTeclado);
    end
endmodule
