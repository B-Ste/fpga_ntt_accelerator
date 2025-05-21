`timescale 1ns / 1ps

module modular_adder_tb();

    reg clk = 0;
    reg [29:0]a;
    reg [29:0]b;
    wire [29:0]c;
    
    modular_adder #1068564481 ma(clk, a, b, c);
    
    always #50 clk = ~clk;
    
    initial
    begin
        a = 1068564480;
        b = 0;
        #100;
        a = 10;
        b = 20;
        #100
        a = 1068564480;
        b = 1;
        #100;
        a = 10;
        b = 1068564480;
        #100;
        a = 1068564480;
        b = 1068564480;
    end

endmodule
