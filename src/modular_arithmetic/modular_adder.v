`timescale 1ns / 1ps

/*
Performs (a + b) mod Q, where a and b are 30-bit numbers, 0 <= a < Q and 0 <= b < Q.
Takes two cc.
*/
module modular_adder(
    input clk, 
    input mod_sel,
    input [3:0]mod_index,
    input [29:0]a, 
    input [29:0]b, 
    output reg [29:0]c
    );
    
    wire [29:0] q;
    reg [3:0] mod_index_internal;
    reg [30:0] sum;

    prime_rom prime_rom (
        .a(mod_index_internal),      // input wire [3 : 0] a
        .spo(q)  // output wire [29 : 0] spo
    );

    always @(posedge clk) 
    begin
        if (mod_sel) mod_index_internal <= mod_index; 
    end
    
    always @(posedge clk)
    begin
        sum <= a + b;
        if (sum >= q)
            c <= sum - q;
        else 
            c <= sum;
    end
endmodule
