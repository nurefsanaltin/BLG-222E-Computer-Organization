`timescale 1ns / 1ps

module CPUSystem(Clock, Reset, T);
    input wire Clock;
    input wire Reset;
    output reg [7:0] T=8'h00;
    
    
    reg[2:0] RF_OutASel, RF_OutBSel, RF_FunSel;
    reg[3:0] RF_RegSel, RF_ScrSel;
    reg[4:0] ALU_FunSel;
    reg ALU_WF; 
    reg[1:0] ARF_OutCSel, ARF_OutDSel;
    reg[2:0] ARF_FunSel, ARF_RegSel;
    reg IR_LH, IR_Write, Mem_WR, Mem_CS;
    reg[1:0] MuxASel, MuxBSel;
    reg MuxCSel;
    
    
    
    ArithmeticLogicUnitSystem _ALUSystem(
            .RF_OutASel(RF_OutASel),   .RF_OutBSel(RF_OutBSel), 
            .RF_FunSel(RF_FunSel),     .RF_RegSel(RF_RegSel),
            .RF_ScrSel(RF_ScrSel),     .ALU_FunSel(ALU_FunSel),
            .ALU_WF(ALU_WF),           .ARF_OutCSel(ARF_OutCSel), 
            .ARF_OutDSel(ARF_OutDSel), .ARF_FunSel(ARF_FunSel),
            .ARF_RegSel(ARF_RegSel),   .IR_LH(IR_LH),
            .IR_Write(IR_Write),       .Mem_WR(Mem_WR),
            .Mem_CS(Mem_CS),           .MuxASel(MuxASel),
            .MuxBSel(MuxBSel),         .MuxCSel(MuxCSel),
            .Clock(Clock)
        );   
 
   
    // Sequence Counter begin
    always@(posedge Clock)   
    begin
        if(T== 8 'h00)
            T <= 8'd1;
        else if(T == 8'd1)
            T <= 8'd2;
        else if(T == 8'd2)
            T <= 8'd4;
        else if(T == 8'd4)
            T <= 8'd8;
        else if(T == 8'd8)
            T <= 8'd16;
        else if(T == 8'd16)
            T <= 8'd32;
        else if(T == 8'd32)
            T <= 8'd64;
        else if(T == 8'd64)
            T <= 8'd128;
        else if(T == 8'd128)
            T <= 8'd1;
    end
     
    

    initial 
    begin
    ARF_FunSel = 3 'b011;
    ARF_RegSel = 3 'b000; 
    Mem_CS <= 1'b1;             // disable
    Mem_WR <= 1'b0;             // don't write
    RF_RegSel <= 4'b0000;       // enable all registers
    RF_ScrSel <= 4'b0000;       // enable all registers 
    RF_FunSel <= 3'b011;        // clear
    end
    


    // Check again
    wire [3:0] ALU_Flags;
    assign ALU_Flags = _ALUSystem.ALU.FlagsOut ;
    wire Z = ALU_Flags[3];
    
    reg [63:0] O;
    reg[1:0] RSel;
    reg [7:0] Address;
    
    
    wire [15:0] IROut;
    assign IROut = _ALUSystem.IR.IROut;     
    
    
    reg S;
    reg [2:0] DSTREG;
    reg [2:0] SREG1;
    reg [2:0] SREG2;
    
 
    
    
    
    always @(*) 
    begin
    if (Reset) 
    begin
        
            if(T[0]) 
            begin
                ARF_OutDSel = 2'b00;    // PC
                Mem_CS = 1'b0;          // enable memory
                Mem_WR = 1'b0;          // read from memory
                IR_LH = 1'b0;           // write low
                IR_Write = 1'b1;        // write IR
                ARF_RegSel = 3'b011;    // select PC
                ARF_FunSel = 3'b001;    // increment
            end
            if(T[1])
            begin
                 ARF_RegSel = 3'b011;   // select PC
                 ARF_FunSel = 3'b001;   // increment
                 ARF_OutDSel = 2'b00;   // PC
                 Mem_CS = 1'b0;         // enable memory
                 Mem_WR = 1'b0;         // read from memory
                 IR_LH = 1'b1;          // write high
                 IR_Write = 1'b1;       // write IR
                 
                 RF_OutASel <= 3'b111;      // to make ALU Out 0
                 ALU_FunSel <= 5'b10000;    // to make ALU Out 0
           end
           if(T[2])
           begin
                case(IROut[15:10])
                    6'h00: O = 64'h000000001;
                    6'h01: O = 64'h000000002;
                    6'h02: O = 64'h000000004;
                    6'h03: O = 64'h000000008;
                    6'h04: O = 64'h000000010;
                    6'h05: O = 64'h000000020;
                    6'h06: O = 64'h000000040;
                    6'h07: O = 64'h000000080;
                    6'h08: O = 64'h000000100;
                    6'h09: O = 64'h000000200;
                    6'h0A: O = 64'h000000400;
                    6'h0B: O = 64'h000000800;
                    6'h0C: O = 64'h000001000;
                    6'h0D: O = 64'h000002000;
                    6'h0E: O = 64'h000004000;
                    6'h0F: O = 64'h000008000;
                    6'h10: O = 64'h000010000;
                    6'h11: O = 64'h000020000;
                    6'h12: O = 64'h000040000;
                    6'h13: O = 64'h000080000;
                    6'h14: O = 64'h000100000;
                    6'h15: O = 64'h000200000;
                    6'h16: O = 64'h000400000;
                    6'h17: O = 64'h000800000;
                    6'h18: O = 64'h001000000;         
                    6'h19: O = 64'h002000000; 
                    6'h1A: O = 64'h004000000;
                    6'h1B: O = 64'h008000000;
                    6'h1C: O = 64'h010000000;
                    6'h1D: O = 64'h020000000;
                    6'h1E: O = 64'h040000000;
                    6'h1F: O = 64'h080000000;
                    6'h20: O = 64'h100000000;
                    6'h21: O = 64'h200000000;
                    default: O = 0;
                endcase
                // RSEL, S , DSTREG, SREG1, SREG2
                RSel = IROut[9:8];
                S = IROut[9];
                DSTREG = IROut[8:6];
                SREG1 = IROut[5:3];
                SREG2 = IROut[2:0];
                Address = IROut[7:0];

                IR_Write <= 1'b0;
                ARF_RegSel <= 3'b111;       // unable SP,PC,AR
                RF_ScrSel = 4'b1111;        // unable S1,2,3,4
                RF_RegSel = 4'b1111;        // unable R1,2,3,4
         
           end
           
           // DETERMINE THE ALUFUNSEL ACCORDING TO OPERATIONS
           if( // 2 Operand cases
              (((T[3]&&SREG1[2]==1 &&SREG2[2]==1) ||
              (T[4]&&SREG1[2]==1 &&SREG2[2]==0 )  ||
              (T[4]&&SREG1[2]==0 &&SREG2[2]==1 )  || 
              (T[5]&&SREG1[2]==0 &&SREG2[2]==0 )) && 
              ( O[12] || O[13] || O[15] || O[16] || O[21] || O[22] || O[23] || O[25] || O[26] || O[27] || O[28] || O[29])) ||             
               // 1 Operand cases
              ((T[3] &&SREG1[2] == 1) ||
               (T[4]&&SREG1[2]==0) && 
               (O[5] || O[6] || O[7] || O[8] || O[9] || O[10] || O[11] || O[14] || O[24])))
            begin
                case(O)
                   64'h000000020 : ALU_FunSel <= 5'b10000; // LOAD A
                   64'h000000040 : ALU_FunSel <= 5'b10000; // LOAD A 
                   64'h000000080 : ALU_FunSel <= 5'b11011; // LSL
                   64'h000000100 : ALU_FunSel <= 5'b11100; // LSR
                   64'h000000200 : ALU_FunSel <= 5'b11101; // ASR
                   64'h000000400 : ALU_FunSel <= 5'b11110; // CSL
                   64'h000000800 : ALU_FunSel <= 5'b11111; // CSR
                   64'h000001000 : ALU_FunSel <= 5'b10111; // AND
                   64'h000002000 : ALU_FunSel <= 5'b11000; // OR
                   64'h000004000 : ALU_FunSel <= 5'b10010; // NOT
                   64'h000008000 : ALU_FunSel <= 5'b11001; // XOR
                   64'h000010000 : ALU_FunSel <= 5'b11010; // NAND
                   64'h000200000 : ALU_FunSel <= 5'b10100; // ADD
                   64'h000400000 : ALU_FunSel <= 5'b10101; // ADC
                   64'h000800000 : ALU_FunSel <= 5'b10110; // SUB
                   64'h001000000 : ALU_FunSel <= 5'b10000; // MOVS
                   64'h002000000 : ALU_FunSel <= 5'b10100; // ADDS
                   64'h004000000 : ALU_FunSel <= 5'b10110; // SUBS
                   64'h008000000 : ALU_FunSel <= 5'b10111; // ANDS
                   64'h010000000 : ALU_FunSel <= 5'b11000; // ORS
                   64'h020000000 : ALU_FunSel <= 5'b11001; // XORS           
                endcase
            end
           
           
            


           
           // O[0] O[1] O[2]
           // PC <- PC + VALUE
           if(O[0] || (O[1] && Z==0 ) || (O[2] && Z==1 ) )
           begin
               // ALU_B <- VALUE( IR )
               if(T[3])
               begin
                  MuxASel <= 2'b11;           // IR
                  RF_FunSel <= 3'b010;        // Load
                  RF_ScrSel <= 4'b0111;       // S1
                  RF_OutASel <= 3'b100;       // S1 send to ALU A
                  ALU_FunSel <= 5'b10000;     // Load A
                  RF_RegSel <=4'b1111;        // unable R1,2,3,4
                  
               end
               // ALU_A <- PC
               else if (T[4])
               begin     
                   ARF_OutCSel <= 2'b00;       // PC
                   MuxASel <= 2'b01;           // OutCSel
                   RF_FunSel <= 3'b010;        // Load                          
                   RF_ScrSel <= 4'b1011;       // S2
                   RF_OutBSel <= 3'b101;       // S2 send to ALU B
                   ALU_FunSel <= 5'b10100;     // ADD (16-bit)
               end
               // PC <- ALU_Out
               else if(T[5])
               begin
                   MuxBSel <= 2'b00;           // ALU Out
                   ARF_RegSel <= 3'b011;       // PC
                   ARF_FunSel <= 3'b010;       // LOAD
                   RF_RegSel <=4'b0000;        // enable R1,2,3,4
                   RF_ScrSel <=4'b0000;        // enable S1,2,3,4
                   RF_FunSel <= 3'b011;        // clear
               end
               else if(T[6])
               begin
                    T <=8'd1;
                    RF_OutASel <= 3'b111;      // to make ALU Out 0
                    ALU_FunSel <= 5'b10000;    // to make ALU Out 0
                    RF_RegSel <=4'b1111;        // unable R1,2,3,4
                    RF_ScrSel <=4'b1111;        // unable S1,2,3,4
                    ARF_RegSel <= 3'b111;       // unable PC,SP,AR
               end
           end
           
           
           // SREG1 FROM RF
           if( (O[5]|| O[6]|| O[7]|| O[8]|| O[9]|| O[10]|| O[11]|| O[12]|| O[13]|| O[14]|| O[15]|| O[16]|| O[21]||O[22]||O[23]||O[24]||O[25]||O[26]||O[27]||O[28]||O[29]) && T[3] && SREG1[2] == 1 )
           begin
               // ALU_A <- SREG1
               RF_OutASel <= {1'b0, SREG1[1:0]};
           end 
               
           //SREG2 FROM RF
           if( (O[12]|| O[13]|| O[15]|| O[16]|| O[21]|| O[22]|| O[23]|| O[25]|| O[26]|| O[27]|| O[28]|| O[29]) && T[3] && SREG2[2] == 1 )
           begin
               // ALU_B <- SREG2
               RF_OutBSel <= {1'b0, SREG2[1:0]};
           end
           
           //SREG1 FROM ARF
           if( (O[5]|| O[6]|| O[7]|| O[8]|| O[9]|| O[10]|| O[11]|| O[12]|| O[13]|| O[14]|| O[15]|| O[16]|| O[21]||O[22]||O[23]||O[24]||O[25]||O[26]||O[27]||O[28]||O[29 ]) && T[3] && SREG1[2] == 0 )
           begin
               // S1 <- SREG1
               // ALU_A <- S1
               case(SREG1[1:0])
                       2'b00: ARF_OutCSel <= 2'b00; // ARF Output is PC
                       2'b01: ARF_OutCSel <= 2'b01; // ARF Output is PC
                       2'b10: ARF_OutCSel <= 2'b11; // ARF Output is SP
                       2'b11: ARF_OutCSel <= 2'b10; // ARF Output is AR
               endcase
               
               MuxASel <= 2'b01;       // OutC
               RF_FunSel <= 3'b010;    // Load
               RF_ScrSel <= 4'b0111;   // Choose S1
               RF_OutASel <= 3'b100;   // S1 send to ALU A
           end
           
           //SREG2 FROM ARF
           if( ((O[12]|| O[13]|| O[15]|| O[16]|| O[21]|| O[22]|| O[23]|| O[25]|| O[26]|| O[27]|| O[28]|| O[29]) && T[4] && SREG2[2] == 0 && SREG1[2] == 0)  // SREG1 in ARF we need one more cycle
           || ((O[12]|| O[13]|| O[15]|| O[16]|| O[21]|| O[22]|| O[23]|| O[25]|| O[26]|| O[27]|| O[28]|| O[29]) && T[3] && SREG2[2] == 0 && SREG1[2] == 1 )) // SREG1 in RF    
           begin
               // S2 <- SREG2
               // ALU_B <- S2
               case(SREG2[1:0])
                       2'b00: ARF_OutCSel <= 2'b00; // ARF Output is PC
                       2'b01: ARF_OutCSel <= 2'b01; // ARF Output is PC
                       2'b10: ARF_OutCSel <= 2'b11; // ARF Output is SP
                       2'b11: ARF_OutCSel <= 2'b10; // ARF Output is AR
               endcase
               MuxASel <= 2'b01;       // Out C
               RF_FunSel <= 3'b010;    // Load
               RF_ScrSel <= 4'b1011;   // Choose S2
               RF_OutBSel <= 3'b101;   // S2 send to ALU B          
           end
           
           
           
           
           // Operations with 1 operand - DSTREG is in RF
           if(((T[3] && SREG1[2]==1) ||
               (T[4] && SREG1[2]==0)) &&
               (O[5] || O[6] || O[7] || O[8] || O[9] || O[10] || O[11] || O[14] || O[24]) &&
               DSTREG[2] == 1)
           begin
               // DSTREG <- ALU_Out
               MuxASel <= 2'b00;
               RF_FunSel <= 3'b010;
               case(DSTREG[1:0])
                   2'b00 : RF_RegSel <= 4'b0111; // R1
                   2'b01 : RF_RegSel <= 4'b1011; // R2
                   2'b10 : RF_RegSel <= 4'b1101; // R3
                   2'b11 : RF_RegSel <= 4'b1110; // R4
               endcase
               
               if((O[24]) && S) 
               begin
                   ALU_WF <= 1'b1;
               end
               else
               begin
                   ALU_WF <= 1'b0;
               end
               RF_ScrSel <= 4'b1111;      
           end

           // Operations with 1 operand - DSTREG is in ARF          
           if(((T[3] && SREG1[2]==1) ||
               (T[4] && SREG1[2]==0)) &&
               (O[5] || O[6] || O[7] || O[8] || O[9] || O[10] || O[11] || O[14] || O[24])&&
               DSTREG[2] == 0)
           begin
               // DSTREG <- ALU_Out
               MuxBSel <= 2'b00;
               ARF_FunSel <= 3'b010;
               case(DSTREG[1:0])
                   2'b00 : ARF_RegSel <= 3'b011; // PC
                   2'b01 : ARF_RegSel <= 3'b011; // PC
                   2'b10 : ARF_RegSel <= 3'b110; // SP
                   2'b11 : ARF_RegSel <= 3'b101; // AR
               endcase 
               
               if((O[24]) && S) 
               begin
                   ALU_WF <= 1'b1;
               end
               else
               begin
                   ALU_WF <= 1'b0;
               end
               RF_ScrSel <= 4'b1111; 
           end
           
           // Operations with 2 operand - DSTREG is in RF          
          if(((T[3] && SREG1[2]==1 &&SREG2[2]==1) ||
              (T[4] && SREG1[2]==1 &&SREG2[2]==0) ||
              (T[4] && SREG1[2]==0 &&SREG2[2]==1) ||
              (T[5] && SREG1[2]==0 &&SREG2[2]==0) ) &&
              (O[12] || O[13] || O[15] || O[16] || O[21] || O[22] || O[23] ||
              O[25] || O[26] || O[27] || O[28] || O[32] || O[29]) &&
              DSTREG[2] == 1)
          begin
              // DSTREG <- ALU_Out
              MuxASel <= 2'b00;
              RF_FunSel <= 3'b010;
              case(DSTREG[1:0])
                  2'b00 : RF_RegSel <= 4'b0111; // R1
                  2'b01 : RF_RegSel <= 4'b1011; // R2
                  2'b10 : RF_RegSel <= 4'b1101; // R3
                  2'b11 : RF_RegSel <= 4'b1110; // R4
              endcase
              
              if((O[25] || O[26] || O[27] || O[28] || O[29]) && S) 
              begin
                  ALU_WF <= 1'b1;
              end
              else
              begin
                  ALU_WF <= 1'b0;
              end
              RF_ScrSel <= 4'b1111;
          end
          
          // Operations with 2 operand - DSTREG is in ARF
          if(((T[3] && SREG1[2]==1 &&SREG2[2]==1) ||
              (T[4] && SREG1[2]==1 &&SREG2[2]==0) ||
              (T[4] && SREG1[2]==0 &&SREG2[2]==1) ||
              (T[5] && SREG1[2]==0 &&SREG2[2]==0) ) &&
              (O[12] || O[13] || O[15] || O[16] || O[21] || O[22] || O[23] ||
               O[25] || O[26] || O[27] || O[28] || O[32] || O[29]) &&
              DSTREG[2] == 0)
          begin
              // DSTREG <- ALU_Out
              MuxBSel <= 2'b00;
              ARF_FunSel <= 3'b010;
              case(DSTREG[1:0])
                  2'b00 : ARF_RegSel <= 3'b011; // PC
                  2'b01 : ARF_RegSel <= 3'b011; // PC
                  2'b10 : ARF_RegSel <= 3'b110; // SP
                  2'b11 : ARF_RegSel <= 3'b101; // AR
              endcase 
              
              if((O[25] || O[26] || O[27] || O[28] || O[29]) && S) 
              begin
                  ALU_WF <= 1'b1;
              end
              else
              begin
                  ALU_WF <= 1'b0;
              end
              RF_ScrSel <= 4'b1111;
          end

           // Increment case - O[5]
           if(((T[4] && SREG1[2]==1) ||
               (T[5] && SREG1[2]==0)) &&
               O[5])
           begin
               if(DSTREG[2] == 0)          // DSTREG is in ARF
               begin
                   ARF_FunSel <= 3'b001;   // Increment
               end
               else                        // DSTREG is in RF
               begin
                   RF_FunSel <= 3'b001;    // Increment
               end
               RF_OutASel <= 3'b111;      // to make ALU Out 0
               ALU_FunSel <= 5'b10000;    // to make ALU Out 0
           end
           
           // Decrement case - O[6]
           if(((T[4] && SREG1[2]==1) ||
               (T[5] && SREG1[2]==0)) &&
               O[6])
           begin
               if(DSTREG[2] == 0)          // DSTREG is in ARF
               begin
                   ARF_FunSel <= 3'b000;   // Decrement
               end
               else                        // DSTREG is in RF
               begin
                   RF_FunSel <= 3'b000;    // Decrement
               end
               RF_OutASel <= 3'b111;      // to make ALU Out 0
               ALU_FunSel <= 5'b10000;    // to make ALU Out 0
           end
           
           //SP <- SP + 1, Rx <- M[SP] 
           if(O[3])
           begin
               if(T[3])
               begin
                   ARF_RegSel <= 3'b110;       // SP
                   ARF_FunSel <= 3'b001;       // Increment
               end
               else if(T[4])
               begin
                  ARF_OutDSel <= 2'b11;        // SP
                  Mem_WR <= 1'b0;              // read from memory
                  Mem_CS <= 1'b0;              // enable
                  MuxASel <= 2'b10;            // memory output
                  RF_FunSel <= 3'b100;         // clear & only write low 
                  case(RSel)
                       2'b00: RF_RegSel <= 4'b0111;    // R1
                       2'b01: RF_RegSel <= 4'b1011;    // R2
                       2'b10: RF_RegSel <= 4'b1101;    // R3
                       2'b11: RF_RegSel <= 4'b1110;    // R4
                  endcase
                  ARF_RegSel <= 3'b110;       // SP
                  ARF_FunSel <= 3'b001;       // Increment
               end
               else if(T[5])
               begin
                  ARF_OutDSel <= 2'b11;        // SP
                  Mem_WR <= 1'b0;              // read from memory
                  Mem_CS <= 1'b0;              // enable
                  MuxASel <= 2'b10;            // memory output
                  RF_FunSel <= 3'b110;         // only write high 
                  case(RSel)
                       2'b00: RF_RegSel <= 4'b0111;    // R1
                       2'b01: RF_RegSel <= 4'b1011;    // R2
                       2'b10: RF_RegSel <= 4'b1101;    // R3
                       2'b11: RF_RegSel <= 4'b1110;    // R4
                  endcase
                  ARF_RegSel <= 3'b111;       // unable PC,SP,AR

               end  
               else if(T[6])
               begin           
                  T <=8'd1;
                  ARF_RegSel <= 3'b111;       // unable PC,SP,AR
                  RF_OutASel <= 3'b111;       // to make ALU Out 0
                  ALU_FunSel <= 5'b10000;     // to make ALU Out 0
                  RF_RegSel <= 4'b0000;       // enable all registers
                  RF_ScrSel <= 4'b0000;       // enable all registers 
                  RF_FunSel <= 3'b011;        // clear
               end
           end
           
           //M[SP] <- Rx, SP <- SP – 1
           if(O[4])
           begin
               if(T[3])
               begin
                   RF_OutASel <= {1'b0, RSel};
                   ALU_FunSel <= 5'b10000;         // Load A
                   MuxCSel <= 1'b0;                // AluOut (7-0)
                   ARF_OutDSel <= 2'b11;               // SP
                   Mem_WR <= 1'b1;                 // write memory
                   Mem_CS <= 1'b0;                 // enable
                   ARF_RegSel <= 3'b110;           // SP
                   ARF_FunSel <= 3'b000;           // decrement
               end
               if(T[4])
               begin
                   MuxCSel <= 1'b1;                // AluOut (8-15)
                   ARF_OutDSel <= 2'b11;               // SP
                   Mem_WR <= 1'b1;                 // write memory
                   Mem_CS <= 1'b0;                 // enable
                   ARF_RegSel <= 3'b110;           // SP
                   ARF_FunSel <= 3'b000;           // decrement   
               end
               if(T[5])
               begin
                   T <=8'd1;
                   ARF_RegSel <= 3'b111;       // unable PC,SP,AR
                   RF_OutASel <= 3'b111;       // to make ALU Out 0
                   ALU_FunSel <= 5'b10000;     // to make ALU Out 0
                   RF_RegSel <= 4'b0000;       // enable all registers
                   RF_ScrSel <= 4'b0000;       // enable all registers 
                   RF_FunSel <= 3'b011;        // clear           
               end
           end


           // DSTREG[15:8] <- IMMEDIATE (8-bit) - O[17]
           // DSTREG[7:0] <- IMMEDIATE (8-bit) - O[20]

           if((O[17] || O[20]) && T[3] )
            begin
                if(T[3])
                begin           
                    MuxASel <= 2'b11;                   // IROut
                    case(RSel)
                        2'b00: RF_RegSel <= 4'b0111;    // R1
                        2'b01: RF_RegSel <= 4'b1011;    // R2
                        2'b10: RF_RegSel <= 4'b1101;    // R3
                        2'b11: RF_RegSel <= 4'b1110;    // R4
                    endcase
                    if(O[17])
                    begin
                        RF_FunSel <= 3'b110;            // only write high
                    end
                    if(O[20])
                    begin
                     RF_FunSel <= 3'b101;                // only write low                                   
                    end
                end
                if(T[4])
                begin
                    T <=8'd1;
                    ARF_RegSel <= 3'b111;       // unable PC,SP,AR
                    RF_OutASel <= 3'b111;       // to make ALU Out 0
                    ALU_FunSel <= 5'b10000;     // to make ALU Out 0
                    RF_RegSel <= 4'b0000;       // enable all registers
                    RF_ScrSel <= 4'b0000;       // enable all registers 
                    RF_FunSel <= 3'b011;        // clear
                end  
            end
            
            // Rx <- M[AR] 
            if(O[18])
            begin
                if(T[3])
                begin
                    ARF_OutDSel <= 2'b10;               // AR
                    Mem_WR <= 1'b0;                     // read from memory
                    Mem_CS <= 1'b0;                     // enable memory  
                end
                if(T[4])
                begin
                    MuxASel <= 2'b10;                   // memory output
                    RF_FunSel <= 3'b100;                // clear & load low
                    case(RSel) // Rx 
                        2'b00:  RF_RegSel <= 4'b0111;   // R1
                        2'b01:  RF_RegSel <= 4'b1011;   // R2
                        2'b10:  RF_RegSel <= 4'b1101;   // R3
                        2'b11:  RF_RegSel <= 4'b1110;   // R4
                    endcase
                    ARF_RegSel <= 3'b101;               // AR
                    ARF_FunSel <= 3'b001;               // increment
                    
                end
                if(T[5])
                begin
                    ARF_OutDSel <= 2'b10;               // AR
                    Mem_WR <= 1'b0;                     // read from memory
                    Mem_CS <= 1'b0;                     // enable memory
                    MuxASel <= 2'b10;                   // memory output
                    RF_FunSel <= 3'b110;                // load high
                    case(RSel) // Rx                         
                        2'b00:  RF_RegSel <= 4'b0111;   // R1
                        2'b01:  RF_RegSel <= 4'b1011;   // R2
                        2'b10:  RF_RegSel <= 4'b1101;   // R3
                        2'b11:  RF_RegSel <= 4'b1110;   // R4
                    endcase
                end
                if(T[6])
                begin
                       T <=8'd1;
                       ARF_RegSel <= 3'b111;       // unable PC,SP,AR
                       RF_OutASel <= 3'b111;       // to make ALU Out 0
                       ALU_FunSel <= 5'b10000;     // to make ALU Out 0
                       RF_RegSel <= 4'b0000;       // enable all registers
                       RF_ScrSel <= 4'b0000;       // enable all registers 
                       RF_FunSel <= 3'b011;        // clear  
                end         
            end
            
         
            // M[AR] <- Rx
            if(O[19])
            begin
                if(T[3])
                begin
                    RF_OutASel <= {1'b0,RSel};      // Rx
                    ALU_FunSel <= 5'b10000;         // A
                    MuxCSel <= 1'b0;                // ALUOut(7-0)  
                    Mem_WR <= 1'b1;                 // write memory
                    Mem_CS <= 1'b0;                 // enable
                    ARF_OutDSel <= 2'b10;           // AR
                    ARF_RegSel <=  3'b101;          // AR
                    ARF_FunSel <= 3'b001;           // increment
                end
                if(T[4])
                begin
                    MuxCSel <= 1'b1;                // ALUOut(15-8) 
                    Mem_WR <= 1'b1;                 // write memory
                    Mem_CS <= 1'b0;                 // enable
                    ARF_OutDSel <= 2'b10;           // AR
                end
                if(T[5])
                begin
                   T <=8'd1;
                   ARF_RegSel <= 3'b111;       // unable PC,SP,AR
                   RF_OutASel <= 3'b111;       // to make ALU Out 0
                   ALU_FunSel <= 5'b10000;     // to make ALU Out 0
                   RF_RegSel <= 4'b0000;       // enable all registers
                   RF_ScrSel <= 4'b0000;       // enable all registers 
                   RF_FunSel <= 3'b011;        // clear 
                end
            end
           
       
           
           //M[SP] <- PC, PC <- Rx
           if(O[30])
           begin
                if(T[3])
                begin
                    ARF_OutCSel <= 2'b00;           // PC
                    MuxASel <= 2'b01;               // out C
                    RF_FunSel <= 3'b010;            // load
                    RF_ScrSel <= 4'b0111;           // S1
                    RF_OutASel <= 3'b100;           // S1
                    ALU_FunSel <= 5'b10000;         // A
                    
                end
                if(T[4])
                begin
                    ARF_OutDSel <= 2'b11;           // SP
                    Mem_WR <= 1'b1;                 // write memory
                    Mem_CS <= 1'b0;                 // enable
                    MuxCSel <= 1'b0;                // ALUOut(7-0)
                    ARF_RegSel <= 3'b110;           // SP
                    ARF_FunSel <= 3'b001;           // increment
                end
                if(T[5])
                begin
                    ARF_OutDSel <= 2'b11;           // SP
                    Mem_WR <= 1'b1;                 // write memory
                    Mem_CS <= 1'b0;                 // enable
                    MuxCSel <= 1'b1;                // ALUOut(15-8)
                end
                if(T[6])
                begin
                    RF_OutBSel <= {1'b0,RSel};      // Rx
                    ALU_FunSel <= 5'b10001;         // B
                    MuxBSel <= 2'b00;               // ALUOut
                    ARF_RegSel <= 3'b011;           // PC
                    ARF_FunSel <= 3'b010;           // load
                end
                if(T[7])
                begin
                   T <=8'd1;
                   ARF_RegSel <= 3'b111;       // unable PC,SP,AR
                   RF_OutASel <= 3'b111;       // to make ALU Out 0
                   ALU_FunSel <= 5'b10000;     // to make ALU Out 0
                   RF_RegSel <= 4'b0000;       // enable all registers
                   RF_ScrSel <= 4'b0000;       // enable all registers 
                   RF_FunSel <= 3'b011;        // clear 
                end        
           end
           
           //PC <- M[SP]
          if(O[31])
          begin
               if(T[3])
               begin
                   ARF_OutDSel <= 2'b11;           // SP
                   Mem_WR <= 1'b0;                 // read from memory
                   Mem_CS <= 1'b0;                 // enable memory
                   MuxBSel <= 2'b10;               // memory output
                   
               end
               if(T[4])
               begin
                   ARF_RegSel <= 3'b011;           // PC
                   ARF_FunSel <= 3'b100;           // clear & load low
                     
               end
               if(T[5])
               begin
                  ARF_RegSel <= 3'b110;           // SP
                  ARF_FunSel <= 3'b001;           // increment 
               
               end
               if(T[6])
               begin
                   ARF_RegSel <= 3'b011;           // PC
                   ARF_FunSel <= 3'b110;           // load high       
               end
               if(T[7])
               begin
                  T <=8'd1;
                  ARF_RegSel <= 3'b111;       // unable PC,SP,AR
                  RF_OutASel <= 3'b111;       // to make ALU Out 0
                  ALU_FunSel <= 5'b10000;     // to make ALU Out 0
                  RF_RegSel <= 4'b0000;       // enable all registers
                  RF_ScrSel <= 4'b0000;       // enable all registers 
                  RF_FunSel <= 3'b011;        // clear                 
               end
           
          end
          
          //Rx <- VALUE (VALUE defined in ADDRESS bits) 
         if(O[32])
         begin
              if(T[3])
              begin
                  MuxBSel <= 2'b11;               // IROut
                  ARF_RegSel <= 3'b101;           // AR
                  ARF_FunSel <= 3'b010;           // load
                  
              end
              if(T[4])
              begin
                  ARF_OutDSel <= 2'b10;           // AR               
                  Mem_WR <= 1'b0;                 // read from memory
                  Mem_CS <= 1'b0;                 // enable
                  MuxASel <= 2'b10;               // memory output                
                  
              end
              if(T[5])
              begin
                    RF_FunSel <= 3'b100;            // clear & load low
                    case(RSel)
                        2'b00: RF_RegSel <= 4'b0111;    // R1
                        2'b01: RF_RegSel <= 4'b1011;    // R2
                        2'b10: RF_RegSel <= 4'b1101;    // R3
                        2'b11: RF_RegSel <= 4'b1110;    // R4
                    endcase
                    ARF_RegSel <= 3'b101;           // AR
                    ARF_FunSel <= 3'b001;           // incement
              
              end
              if(T[6])
              begin
                  RF_FunSel <= 3'b110;            // load high
                  case(RSel)
                      2'b00: RF_RegSel <= 4'b0111;    // R1
                      2'b01: RF_RegSel <= 4'b1011;    // R2
                      2'b10: RF_RegSel <= 4'b1101;    // R3
                      2'b11: RF_RegSel <= 4'b1110;    // R4
                  endcase
              end
              if(T[7])
              begin
                T <=8'd1;
                ARF_RegSel <= 3'b111;       // unable PC,SP,AR
                RF_OutASel <= 3'b111;       // to make ALU Out 0
                ALU_FunSel <= 5'b10000;     // to make ALU Out 0
                RF_RegSel <= 4'b0000;       // enable all registers
                RF_ScrSel <= 4'b0000;       // enable all registers 
                RF_FunSel <= 3'b011;        // clear 
              
              end

         end
         
         //M[AR+OFFSET] ? Rx (AR is 16-bit register) (OFFSET defined in ADDRESS bits)
         if(O[33])
         begin
            if(T[3])
            begin
                ARF_OutCSel <= 2'b10;           //AR
                MuxASel <= 2'b01;               //AR
                RF_FunSel <= 3'b010;            //LOAD
                RF_ScrSel <= 4'b0111;           //S1
                RF_OutASel <= 3'b100;           //S1
            end
            if(T[4])
            begin
                MuxASel <= 2'b11;               // IR
                RF_ScrSel <= 4'b1011;           // S2
                RF_FunSel <=3'b010;             // Load
                RF_OutBSel <= 3'b101;           // S2
                ALU_FunSel <= 5'b10100;         // A+B
            end
            if(T[5])
            begin
                MuxBSel <= 2'b00;               // ALU Out
                ARF_FunSel <=3'b010;            // Load
                ARF_RegSel <= 3'b101;           // AR
            end
            if(T[6])
            begin
                RF_OutASel <=  {1'b0,RSel};     // Rx
                ALU_FunSel <= 5'b10000;         // Load A
                MuxCSel <= 1'b0;                // ALU Out(7-0)
                Mem_WR <= 1'b1;
                Mem_CS <= 1'b0;
                ARF_OutDSel <= 2'b10;           // AR
                ARF_RegSel <= 3'b101;           // AR
                ARF_FunSel <= 3'b001;           // increment
            end
            if(T[7])
            begin
                MuxCSel <= 1'b1;                // ALU Out(7-0)
                Mem_WR <= 1'b1;
                Mem_CS <= 1'b0; 
                ARF_RegSel <= 3'b111;       // unable PC,SP,AR
                RF_RegSel <= 4'b0000;       // enable all registers
                RF_ScrSel <= 4'b0000;       // enable all registers 
                RF_FunSel <= 3'b011;        // clear       
            end
         end
           
           
           // Increment&Decrement ends
           if((((T[5] && SREG1[2]==1) || (T[6] && SREG1[2]==0)) && O[5]) || 
           (((T[5] && SREG1[2]==1) || (T[6] && SREG1[2]==0)) && O[6]))
           begin             
               T <=8'd1;
               RF_RegSel <=4'b1111;        // unable R1,2,3,4
               RF_ScrSel <=4'b1111;        // unable S1,2,3,4
               ARF_RegSel <= 3'b111;       // unable PC,SP,AR         
           end
           
           // RESET THE SYSTEM AFTER OPERATIONS WITH SREG1 AND SREG2
             if(( ((T[4] && SREG1[2]==1 &&SREG2[2]==1) ||
                   (T[5] && SREG1[2]==1 &&SREG2[2]==0) ||
                   (T[5] && SREG1[2]==0 &&SREG2[2]==1) ||
                   (T[6] && SREG1[2]==0 &&SREG2[2]==0) ) &&
                   (O[12] || O[13] || O[15] || O[16] || O[21] || O[22] || O[23] || O[25] || O[26] || O[27] || O[28] || O[29])) 
                || 
               (   ((T[4] && SREG1[2]==1) ||
                   (T[5] && SREG1[2]==0)) &&
                   (O[7] || O[8] || O[9] || O[10] || O[11] || O[14] || O[24])) )
            begin           
               T <=8'd1;
               ARF_RegSel <= 3'b111;       // unable PC,SP,AR
               RF_OutASel <= 3'b111;       // to make ALU Out 0
               ALU_FunSel <= 5'b10000;     // to make ALU Out 0
               RF_RegSel <= 4'b0000;       // enable all registers
               RF_ScrSel <= 4'b0000;       // enable all registers 
               RF_FunSel <= 3'b011;        // clear
            end
           
          
        
    end
    else
    begin
        T <= 8'd1; 
    end
    end     
     
endmodule