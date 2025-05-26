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

    parameter mod_index = 0;
    wire [29:0]q;

    generate
        if (mod_index == 4'd0)
            assign q = 1063321601;
        else if (mod_index == 4'd1)
            assign q = 1063452673;
        else if (mod_index == 4'd2)
            assign q = 1064697857;
        else if (mod_index == 4'd3)
            assign q = 1065484289;
        else if (mod_index == 4'd4)
            assign q = 1065811969;
        else if (mod_index == 4'd5)
            assign q = 1068236801;
        else if (mod_index == 4'd6)
            assign q = 1068433409;
        else if (mod_index == 4'd7)
            assign q = 1068564481;
        else if (mod_index == 4'd8)
            assign q = 1069219841;
        else if (mod_index == 4'd9)
            assign q = 1070727169;
        else if (mod_index == 4'd10)
            assign q = 1071513601;
        else if (mod_index == 4'd11)
            assign q = 1072496641;
        else
            assign q =1073479681;
    endgenerate
    
    wire signed [30:0]as = {1'b0, a};
    wire signed [30:0]bs = {1'b0, b};
    
    reg signed[30:0] sub;
    
    always @(posedge clk)
    begin
        sub <= as - bs;
        if (sub < 0)
            c <= sub + q;
        else 
            c <= sub;
    end
endmodule
