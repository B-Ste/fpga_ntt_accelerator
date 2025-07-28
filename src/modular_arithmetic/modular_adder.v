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

    parameter MOD_INDEX = 0;
    wire [29:0] q;

    generate
        if (MOD_INDEX == 4'd0)
            assign q = 1063321601;
        else if (MOD_INDEX == 4'd1)
            assign q = 1063452673;
        else if (MOD_INDEX == 4'd2)
            assign q = 1064697857;
        else if (MOD_INDEX == 4'd3)
            assign q = 1065484289;
        else if (MOD_INDEX == 4'd4)
            assign q = 1065811969;
        else if (MOD_INDEX == 4'd5)
            assign q = 1068236801;
        else if (MOD_INDEX == 4'd6)
            assign q = 1068433409;
        else if (MOD_INDEX == 4'd7)
            assign q = 1068564481;
        else if (MOD_INDEX == 4'd8)
            assign q = 1069219841;
        else if (MOD_INDEX == 4'd9)
            assign q = 1070727169;
        else if (MOD_INDEX == 4'd10)
            assign q = 1071513601;
        else if (MOD_INDEX == 4'd11)
            assign q = 1072496641;
        else
            assign q =1073479681;
    endgenerate

    wire [30:0] sum = a + b;
    
    always @(posedge clk)
    begin
        //sum <= a + b;
        if (sum >= q)
            c <= sum - q;
        else 
            c <= sum;
    end
endmodule
