`timescale 1ns / 1ps
module RegisterFile(Clock,OutASel,OutBSel,FunSel,RegSel,ScrSel,I,OutA,OutB);
    input wire Clock;
    input wire [2:0] OutASel;
    input wire [2:0] OutBSel;
    input wire [2:0] FunSel;
    input wire [3:0] RegSel;
    input wire [3:0] ScrSel;
    
    input wire [15:0] I;
    
    output reg [15:0] OutA;
    output reg [15:0] OutB;
        
    wire [15:0] R_1,R_2,R_3,R_4;
    wire [15:0] S_1,S_2,S_3,S_4;
    
    wire E_R1,E_R2,E_R3,E_R4;
    wire E_S1,E_S2,E_S3,E_S4;

    assign {E_R1,E_R2,E_R3,E_R4} = ~RegSel;
    assign {E_S1,E_S2,E_S3,E_S4} = ~ScrSel;
    
    
    Register R1 ( .Clock(Clock),.FunSel(FunSel),.E(E_R1),.I(I),.Q(R_1));
    Register R2 ( .Clock(Clock),.FunSel(FunSel),.E(E_R2),.I(I),.Q(R_2));
    Register R3 ( .Clock(Clock),.FunSel(FunSel),.E(E_R3),.I(I),.Q(R_3));
    Register R4 ( .Clock(Clock),.FunSel(FunSel),.E(E_R4),.I(I),.Q(R_4));
    
    Register S1 ( .Clock(Clock),.FunSel(FunSel),.E(E_S1),.I(I),.Q(S_1));
    Register S2 ( .Clock(Clock),.FunSel(FunSel),.E(E_S2),.I(I),.Q(S_2));
    Register S3 ( .Clock(Clock),.FunSel(FunSel),.E(E_S3),.I(I),.Q(S_3));
    Register S4 ( .Clock(Clock),.FunSel(FunSel),.E(E_S4),.I(I),.Q(S_4));
    
   
    always@(*)
    begin
        case(OutASel)
                3'b000: OutA <= R_1;
                3'b001: OutA <= R_2;
                3'b010: OutA <= R_3;
                3'b011: OutA <= R_4;
                3'b100: OutA <= S_1;
                3'b101: OutA <= S_2;
                3'b110: OutA <= S_3;
                3'b111: OutA <= S_4;         
        endcase
        
        case(OutBSel)
                3'b000: OutB <= R_1;
                3'b001: OutB <= R_2;
                3'b010: OutB <= R_3;
                3'b011: OutB <= R_4;
                3'b100: OutB <= S_1;
                3'b101: OutB <= S_2;
                3'b110: OutB <= S_3;
                3'b111: OutB <= S_4;         
        endcase
    end
endmodule