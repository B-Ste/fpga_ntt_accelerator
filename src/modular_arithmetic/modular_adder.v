`timescale 1ns / 1ps

/*
Performs (a + b) mod Q, where a and b are 30-bit numbers, 0 <= a < Q and 0 <= b < Q.
Takes two cc.
*/
module modular_adder(
    input clk, 
    input [29:0]a, 
    input [29:0]b, 
    output reg [29:0]c
    );
    
    parameter Q = 30'b0;
    
    reg [30:0] sum;
    
    always @(posedge clk)
    begin
        sum <= a + b;
        if (sum >= Q)
            c <= sum - Q;
        else 
            c <= sum;
    end
endmodule
