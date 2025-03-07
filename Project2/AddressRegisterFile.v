`timescale 1ns / 1ps
module AddressRegisterFile(Clock,I,OutCSel,OutDSel,FunSel,RegSel,OutC,OutD);
    input wire Clock;
    input wire [15:0] I;
    input wire [1:0]OutCSel;
    input wire [1:0]OutDSel;
    input wire [2:0]FunSel;
    input wire [2:0]RegSel;
    
    output reg [15:0] OutC;
    output reg [15:0] OutD;
    
    wire [15:0] P_C;
    wire [15:0] A_R;
    wire [15:0] S_P;

    wire E_PC, E_AR, E_SP;
    
    assign {E_PC, E_AR, E_SP} = ~RegSel;
    
    Register PC ( .Clock(Clock),.FunSel(FunSel),.E(E_PC),.I(I),.Q(P_C));
    Register AR ( .Clock(Clock),.FunSel(FunSel),.E(E_AR),.I(I),.Q(A_R));
    Register SP ( .Clock(Clock),.FunSel(FunSel),.E(E_SP),.I(I),.Q(S_P));


always@(*)
    begin
        case(OutCSel)
            2'b00: OutC <= P_C;
            2'b01: OutC <= P_C;
            2'b10: OutC <= A_R;
            2'b11: OutC <= S_P;
        endcase
        case(OutDSel)
            2'b00: OutD <= P_C;
            2'b01: OutD <= P_C;
            2'b10: OutD <= A_R;
            2'b11: OutD <= S_P;
        endcase
    end

endmodule