`timescale 1ns/1ps

module modular_multiplier (
    input clk, 
    input [29:0]a, 
    input [29:0]b, 
    output [29:0]c);

    parameter MOD_INDEX = 0;
    
    reg [59:0]product;

    windowed_reduction60bit #MOD_INDEX reduction(
	    .clk(clk), 
        .in(product), 
        .out(c));
        
    always @(posedge clk) product <= a * b;

endmodule