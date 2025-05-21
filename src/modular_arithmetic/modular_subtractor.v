`timescale 1ns / 1ps

/*
Performs (a - b) mod Q, where a and b are 30-bit numbers, 0 <= a < Q and 0 <= b < Q.
Takes two cc.
*/
module modular_subtractor(
    input clk, 
    input [29:0]a, 
    input [29:0]b, 
    output reg [29:0]c);
    
    parameter Q = 30'b0;
    
    wire signed [30:0]as = {1'b0, a};
    wire signed [30:0]bs = {1'b0, b};
    
    reg signed[30:0] sub;
    
    always @(posedge clk)
    begin
        sub <= as - bs;
        if (sub < 0)
            c <= sub + Q;
        else 
            c <= sub;
    end
endmodule
