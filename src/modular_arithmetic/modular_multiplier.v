`timescale 1ns/1ps

module modular_multiplier (
    input clk, 
    input [29:0]a, 
    input [29:0]b, 
    output [29:0]c);

    parameter MOD_INDEX = 0;
    
    reg [29:0]a_reg, b_reg;
    reg [59:0]product;

    windowed_reduction60bit #MOD_INDEX reduction(
	    .clk(clk), 
        .in(product), 
        .out(c));
        
    always @(posedge clk) begin
        product <= a_reg * b_reg;
        a_reg <= a;
        b_reg <= b;
    end

endmodule