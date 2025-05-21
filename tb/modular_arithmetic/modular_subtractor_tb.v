`timescale 1ns / 1ps

module modular_subtractor_tb();

    reg clk = 0;
    reg [29:0]a;
    reg [29:0]b;
    wire [29:0]c;
    
    modular_subtractor #1068564481 ms(clk, a, b, c);
    
    always #50 clk = ~clk;
    
    initial
    begin
        a = 10;
        b = 0;
        #100;
        a = 10;
        b = 8;
        #100
        a = 10;
        b = 11;
        #100;
        a = 0;
        b = 1068564480;
        #100;
        a = 1068564480;
        b = 0;
        #100
        a = 1068564480;
        b = 1068564480;
    end

endmodule
