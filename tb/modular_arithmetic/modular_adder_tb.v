`timescale 1ns / 1ps

module modular_adder_tb();

    reg clk = 0;
    reg [29:0]a;
    reg [29:0]b;
    reg [3:0]mod_index;
    reg mod_sel;
    wire [29:0]c;
    
    modular_adder ma(clk, mod_sel, mod_index, a, b, c);
    
    always #50 clk = ~clk;
    
    initial
    begin
        mod_index = 7;
        mod_sel = 1;
        #100;
        mod_sel = 0;
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
