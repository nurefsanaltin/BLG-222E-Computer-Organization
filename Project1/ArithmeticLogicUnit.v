`timescale 1ns / 1ps
module ArithmeticLogicUnit(Clock,A,B,FunSel,ALUOut,FlagsOut,WF);
    input wire Clock;
    input wire [15:0] A;
    input wire [15:0] B;
    input wire [4:0] FunSel;
    input wire WF;
    
    output reg [15:0] ALUOut;
    output reg [3:0] FlagsOut;
    
    reg Z = 0;
    reg C = 0;
    reg N = 0;
    reg O = 0;
    
    reg [15:0] internal_sum;
    
    
    always@(*)
    begin
        case(FunSel)
            5'b00000: // A
            begin
                ALUOut[7:0] = A[7:0];           
            end
            5'b00001: // B
            begin
                ALUOut[7:0] = B[7:0];  
            end
            5'b00010: // NOT A
            begin
                ALUOut[7:0] = ~A[7:0]; 
            end
            5'b00011: // NOT B
            begin
                ALUOut[7:0] = ~B[7:0]; 
            end
            5'b00100: // A + B
            begin 
                ALUOut[7:0] =  A[7:0] + B[7:0];
            end
            5'b00101: // A + B + Carry
            begin
                ALUOut[7:0] = A[7:0] + B[7:0] + {7'b0 ,C} ;                 
            end
            5'b00110: // A - B
            begin
                ALUOut[7:0] =  A[7:0] + ~B[7:0] + 8'b1; 
            end
            5'b00111: // A AND B
            begin
                 ALUOut[7:0] = A[7:0] & B[7:0];
            end
            5'b01000: // A OR B
            begin
                ALUOut[7:0] = A[7:0] | B[7:0];                   
            end
            5'b01001: // A XOR B
            begin
                ALUOut[7:0] = A[7:0] ^ B[7:0];
            end
            5'b01010: // A NAND B
            begin
                ALUOut[7:0] = ~(A[7:0] & B[7:0]);
            end
            5'b01011: // LSL A
            begin
                ALUOut[15:8] = {8'b0};               
                ALUOut[7:0] = {A[6:0],1'b0};                                  
            end
            5'b01100: // LSR A
            begin
                ALUOut[15:8] = {8'b0};                            
                ALUOut[7:0] = {1'b0,A[7:1]};
            end
            5'b01101: // ASR A
            begin
                ALUOut[15:8] = {8'b0};
                ALUOut[7:0] = {A[7],A[7:1]};
            end
            5'b01110: // CSL A
            begin
                ALUOut[15:8] = {8'b0};
                ALUOut[7:0] = {A[6:0],A[7]};
            end
            5'b01111: // CSR A
            begin
                ALUOut[15:8] = {8'b0};
                ALUOut[7:0] = {A[0],A[7:1]};
            end
            
            5'b10000: // A
            begin
                ALUOut = A;
            end
            5'b10001: // B
            begin
                ALUOut = B;                 
            end
            5'b10010: // NOT A
            begin
                ALUOut = ~A;
            end
            5'b10011:
            begin // NOT B
                ALUOut = ~B;
            end
            5'b10100: // A + B
            begin
                ALUOut = A + B;                  
            end
            5'b10101: // A + B + Carry
            begin
                ALUOut = A + B + {15'b0,C};
            end
            5'b10110: // A - B
            begin
                ALUOut = A + ~B + 16'b1;

            end
            5'b10111: // A AND B
            begin
                ALUOut = A & B;                 
            end
            5'b11000: // A OR B
            begin
                ALUOut = A | B;                   
            end
            5'b11001: // A XOR B
            begin
                ALUOut = A ^ B;                   
            end
            5'b11010: // A NAND B
            begin
                ALUOut = ~(A & B);
            end
            5'b11011: // LSL A
            begin               
                ALUOut = {A[14:0],1'b0}; 
            end
            5'b11100: // LSR A
            begin                          
                ALUOut = {1'b0,A[15:1]};
            end
            5'b11101: // ASR A
            begin
                ALUOut = {A[15],A[15:1]};
            end
            5'b11110: // CSL A
            begin
                ALUOut = {A[14:0],A[15]};                 
            end
            5'b11111: // CSR A
            begin
                ALUOut = {A[0],A[15:1]};  
            end
            
        endcase
    end
    
    always@(posedge Clock)
        begin
            case(FunSel)
                5'b00000: // A
                begin
                    N = ALUOut[7];                 
                end
                5'b00001: // B
                begin
                    N = ALUOut[7];  
                end
                5'b00010: // NOT A
                begin  
                    N = ALUOut[7];  
                end
                5'b00011: // NOT B
                begin                                 
                    N = ALUOut[7];  
                end
                5'b00100: // A + B
                begin 
                    {C,internal_sum[7:0]} =  {1'b0,A[7:0]} + {1'b0,B[7:0]};
                                                     
                    N = ALUOut[7];
                    if(~(A[7]^B[7])&(ALUOut[7]^A[7]))
                    begin
                        O = 1;
                    end
                end
                5'b00101: // A + B + Carry
                begin
                    {C,internal_sum[7:0]} = {1'b0,A[7:0]} + {1'b0,B[7:0]} + {8'b0 ,C} ; 
                                                                 
                    N = ALUOut[7];
                    if(~(A[7]^B[7])&(ALUOut[7]^A[7]))
                    begin
                        O = 1;
                    end
                      
                end
                5'b00110: // A - B
                begin
                    {C,internal_sum[7:0]} =  {1'b0,A[7:0]} + {1'b0,~B[7:0]} + 9'b1;  
                                                                 
                    N = ALUOut[7];
                    if((A[7]^B[7])&(ALUOut[7]^A[7]))
                    begin
                        O = 1;
                    end
                      
                end
                5'b00111: // A AND B
                begin
                     N = ALUOut[7];
                end
                5'b01000: // A OR B
                begin
                     N = ALUOut[7];                      
                end
                5'b01001: // A XOR B
                begin
                     N = ALUOut[7];                      
                end
                5'b01010: // A NAND B
                begin
                     N = ALUOut[7];                    
                end
                5'b01011: // LSL A
                begin
                    C = A[7];
                    N = ALUOut[7];                                     
                end
                5'b01100: // LSR A
                begin
                    C = A[0]; 
                    N = ALUOut[7];                                  
                end
                5'b01101: // ASR A
                begin
                    C = A[0];
                end
                5'b01110: // CSL A
                begin
                    N = ALUOut[7];
                    C = A[7];                      
                end
                5'b01111: // CSR A
                begin
                    N = ALUOut[7];
                    C = A[0];
                end               
                5'b10000: // A
                begin              
                    N = ALUOut[15];
                end
                5'b10001: // B
                begin    
                    N = ALUOut[15];
                     
                end
                5'b10010: // NOT A
                begin   
                    N = ALUOut[15];
                end
                5'b10011:
                begin // NOT B                        
                    N = ALUOut[15];
                end
                5'b10100: // A + B
                begin
                    {C,internal_sum} = {1'b0,A} + {1'b0,B};                    
                    
                    N = ALUOut[15];
                    if(~(A[15]^B[15])&(ALUOut[15]^A[15]))
                    begin
                        O = 1;
                    end
                end
                5'b10101: // A + B + Carry
                begin
                      {C,internal_sum} = {1'b0,A} + {1'b0,B} + {16'b0,C};
                      
                      N = ALUOut[15];
                      if(~(A[15]^B[15])&(ALUOut[15]^A[15]))
                      begin
                          O = 1;
                      end
                end
                5'b10110: // A - B
                begin
                    {C,internal_sum} = {1'b0,A} + {1'b0,~B} + 17'b1;
                    
                    N = ALUOut[15];
                    if((A[15]^B[15])&(ALUOut[15]^A[15]))
                    begin
                        O = 1;
                    end
                end
                5'b10111: // A AND B
                begin 
                    N = ALUOut[15];
                      
                end
                5'b11000: // A OR B
                begin            
                    N = ALUOut[15];
                       
                end
                5'b11001: // A XOR B
                begin           
                    N = ALUOut[15];
                       
                end
                5'b11010: // A NAND B
                begin     
                    N = ALUOut[15];
                end
                5'b11011: // LSL A
                begin               
                    C = A[15];
                    N = ALUOut[15];
                      
                end
                5'b11100: // LSR A
                begin                          
                    C = A[0]; 
                    N = ALUOut[15];
                     
                end
                5'b11101: // ASR A
                begin
                    C = A[0];
                end
                5'b11110: // CSL A
                begin
                    N = ALUOut[15];
                    C = A[15];
                     
                end
                5'b11111: // CSR A
                begin
                    N = ALUOut[15];
                    C = A[0];   
                end
                
            endcase
            
            if((FunSel[4]==0 & ALUOut[7:0] == {8'b0}) | (FunSel[4]==1 & ALUOut[15:0] == {16'b0}))
            begin
                Z = 1;
            end
            
            if(WF==1)
            begin
                FlagsOut <= {Z,C,N,O};
            end
        end
endmodule