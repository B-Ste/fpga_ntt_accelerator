`timescale 1ns/1ps

module modular_multiplier (
    input clk, 
    input [29:0]a, 
    input [29:0]b, 
    output [29:0]c);

    parameter mod_index = 0;

    windowed_reduction60bit #mod_index reduction(
	    .clk(clk), 
        .in(a * b), 
        .out(c));

endmodule