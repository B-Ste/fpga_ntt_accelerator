`timescale 1ns/1ps

module modular_multiplier (
    input clk, 
    input [29:0]a, 
    input [29:0]b, 
    output reg [59:0]c);

    wire [59:0]mult_result;

    dsp_multiplier mult (
        .CLK(clk),  // input wire CLK
        .A(a),      // input wire [29 : 0] A
        .B(b),      // input wire [29 : 0] B
        .P(mult_result)      // output wire [59 : 0] P
    );

    always @(posedge clk) begin
        c <= mult_result;
    end
    
endmodule