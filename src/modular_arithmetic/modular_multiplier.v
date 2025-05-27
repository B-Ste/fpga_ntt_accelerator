`timescale 1ns/1ps

module modular_multiplier (
    input clk, 
    input [29:0]a, 
    input [29:0]b, 
    output [29:0]c);

    parameter mod_index = 0;

    wire [59:0]mult_out;

    dsp_multiplier mult (
        .CLK(clk),  // input wire CLK
        .A(a),      // input wire [29 : 0] A
        .B(b),      // input wire [29 : 0] B
        .P(mult_out)      // output wire [59 : 0] P
    );

    windowed_reduction60bit #mod_index reduction(
	    .clk(clk), 
        .in(mult_out), 
        .out(c));

endmodule