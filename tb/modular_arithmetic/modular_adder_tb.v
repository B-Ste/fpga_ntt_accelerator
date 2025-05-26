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

    integer i;
    
    initial
    begin
        for (i = 0; i < 13; i = i + 1) begin
            mod_index <= i;
            mod_sel <= 1;
            #100
            mod_sel <= 0;
            a <= 1063321600;
            b <= 1;
            #100;
            a <= 1063452672;
            #100;
            a <= 1064697856;
            #100;
            a <= 1065484288;
            #100;
            a <= 1065811968;
            #100; 
            a <= 1068236800;
            #100;
            a <= 1068433408;
            #100;
            a <= 1068564480;
            #100;
            a <= 1069219840;
            #100;
            a <= 1070727168;
            #100;
            a <= 1071513600;
            #100;
            a <= 1072496640;
            #100;
            a <= 1073479680;
            #100;
            a <= 0;
            b <= 0;
            #100;
            a <= 100;
            b <= 123;
            #100;
            a <= 9354;
            b <= 1239384;
        end
    end

endmodule
