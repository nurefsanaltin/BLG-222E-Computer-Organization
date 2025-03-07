`timescale 1ns / 1ps
module Register(Clock,FunSel,E,I,Q);
    input wire   Clock;                //clock
    input wire   E;                  //enable
    input wire   [2:0] FunSel;       //control signals
    input wire   [15:0] I;           //input for load
    
    
    output reg  [15:0] Q;           //output
    
    always@(posedge Clock) begin
        if(E)
        begin
            case(FunSel)
            
                3'b000: Q <= Q - 16'd1;         //decrement
                3'b001: Q <= Q + 16'd1;         //increment
                3'b010: Q <= I;                 //load
                3'b011: Q <= 16'd0;             //clear
                3'b100:                         
                    begin
                    Q[15:8] <= 8'd0;            //Q (15-8) ? Clear
                    Q[7:0] <= I[7:0];           //Q (7-0) ? I (7-0) (Write Low)
                    end
                3'b101: Q[7:0] <= I[7:0];       //Q (7-0) ? I (7-0) (Only Write Low)
                3'b110: Q[15:8] <= I[7:0];      //Q (15-8) ? I (7-0) (Only Write High)
                3'b111: 
                    begin
                    Q[15:8] <= {8{I[7]}};       //Q (15-8) ? Sign Extend (I (7))
                    Q[7:0] <= I[7:0];           //Q (7-0) ? I (7-0) (Write Low)
                    end
                default: Q<=Q;
            endcase
        end
        else
        begin
            Q<=Q;
        end      
    end
endmodule