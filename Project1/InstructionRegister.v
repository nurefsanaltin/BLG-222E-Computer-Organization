`timescale 1ns / 1ps
module InstructionRegister(Clock,I,IROut,LH,Write);
    input wire Clock;                 //clock
    input wire [7:0] I;             //input for load
    input wire LH;                 //lower or higher
    input wire Write;              
    
    output reg [15:0]IROut;         //output
    
    
    always@(posedge Clock)
    begin
        if(Write)
        begin
            if(LH)
               begin
                    IROut[15:8] <= I;    //IR (15-8) ? I (Load MSB)
                    
               end
            else
               begin
                   IROut[7:0] <= I;     //IR (7-0) ? I (Load LSB)
               end
        end
        else
        begin
                 IROut <= IROut;            //IR (retain value)
        end
    end

endmodule