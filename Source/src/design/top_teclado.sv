module top_teclado (
    input clk_27MHz,
    input reset_button,
    input [3:0] Row,
    output [3:0] Col
);
    wire n_reset;
    wire [3:0] key_code;
    wire key_valid;
    wire key_ready;
    wire key_read;

    wire [9:0] num1, num2;
    wire num1_done, num2_done, sum_ready;

    Debounce u_db (
        .clk(clk_27MHz),
        .n_reset(1'b1),
        .button_in(reset_button),
        .DB_out(n_reset)
    );

    Hex_Keypad_Grayhill_072 u_keypad (
        .Row(Row),
        .S_Row(1'b0),
        .clock(clk_27MHz),
        .reset(~n_reset),
        .Code(key_code),
        .Valid(key_valid),
        .Col(Col)
    );

    mod_lecturaTeclado u_lectura (
        .Clock(clk_27MHz),
        .Reset_n(n_reset),
        .KeyData(key_code),
        .KeyReady(key_valid),
        .KeyRead(key_read),
        .Num1_value(num1),
        .Num2_value(num2),
        .Num1_done(num1_done),
        .Num2_done(num2_done),
        .Sum_ready(sum_ready)
    );
endmodule
