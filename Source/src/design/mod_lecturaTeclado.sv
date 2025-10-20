// mod_lecturaTeclado.v
// Recibe la salida del KeyPadInterpreter y permite ingresar 2 números de 3 dígitos.
// '*' (4'hF) confirma NUM1, '#' (4'hE) confirma NUM2.

module mod_lecturaTeclado (
    input        Clock,
    input        Reset_n,
    input  [3:0] KeyData,
    input        KeyReady,
    output reg   KeyRead,
    output reg [9:0] Num1_value,
    output reg [9:0] Num2_value,
    output reg        Num1_done,
    output reg        Num2_done,
    output reg        Sum_ready,
    output reg [3:0] disp_hundreds,
    output reg [3:0] disp_tens,
    output reg [3:0] disp_units,
    output reg [1:0] active_field
);
    localparam S_IDLE=3'd0, S_INPUT1=3'd1, S_INPUT2=3'd2, S_DONE=3'd3;
    reg [2:0] state;
    reg [3:0] n1_d2,n1_d1,n1_d0,n2_d2,n2_d1,n2_d0;
    reg keyready_q;
    wire keyready_rise = (KeyReady && !keyready_q);

    always @(posedge Clock or negedge Reset_n) begin
        if (!Reset_n) begin
            state<=S_IDLE; keyready_q<=0; KeyRead<=0;
            n1_d2<=0; n1_d1<=0; n1_d0<=0; n2_d2<=0; n2_d1<=0; n2_d0<=0;
            Num1_value<=0; Num2_value<=0;
            Num1_done<=0; Num2_done<=0; Sum_ready<=0;
            disp_hundreds<=0; disp_tens<=0; disp_units<=0;
            active_field<=0;
        end else begin
            keyready_q<=KeyReady;
            KeyRead<=0;
            case(state)
                S_IDLE: begin
                    Num1_done<=0; Num2_done<=0; Sum_ready<=0;
                    n1_d2<=0; n1_d1<=0; n1_d0<=0;
                    n2_d2<=0; n2_d1<=0; n2_d0<=0;
                    active_field<=2'd1;
                    state<=S_INPUT1;
                end
                S_INPUT1: if (keyready_rise) begin
                    if (KeyData<=4'h9) begin
                        n1_d2<=n1_d1; n1_d1<=n1_d0; n1_d0<=KeyData;
                        disp_hundreds<=n1_d1; disp_tens<=n1_d0; disp_units<=KeyData;
                        KeyRead<=1;
                    end else if (KeyData==4'hF) begin
                        Num1_done<=1; Num1_value<=(n1_d2*100)+(n1_d1*10)+n1_d0;
                        KeyRead<=1; active_field<=2'd2; state<=S_INPUT2;
                    end else KeyRead<=1;
                end
                S_INPUT2: if (keyready_rise) begin
                    if (KeyData<=4'h9) begin
                        n2_d2<=n2_d1; n2_d1<=n2_d0; n2_d0<=KeyData;
                        disp_hundreds<=n2_d1; disp_tens<=n2_d0; disp_units<=KeyData;
                        KeyRead<=1;
                    end else if (KeyData==4'hE) begin
                        Num2_done<=1; Num2_value<=(n2_d2*100)+(n2_d1*10)+n2_d0;
                        KeyRead<=1; active_field<=2'd3; state<=S_DONE;
                    end else KeyRead<=1;
                end
                S_DONE: Sum_ready<=(Num1_done & Num2_done);
            endcase
        end
    end
endmodule
