`timescale 1ns/1ps

module modular_multiplier_tb ();

    reg clk = 0;
    reg [29:0]a;
    reg [29:0]b;
    wire [59:0]c;

    modular_multiplier mm (clk, a, b, c);

    always #50 clk = ~clk;

    initial
    begin
        a = 10;
        b = 10;
        #100;
        a = 5;
        b = 5;
        #100;
        a = 123456;
        b = 7891234;
        #100;
        a = 0;
        b = 10000;
        #100;
        a = 90;
        b = 30;
        #100;
        a = 40;
        b = 23;
    end
    
endmodule
