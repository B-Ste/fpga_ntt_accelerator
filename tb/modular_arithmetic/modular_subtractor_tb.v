`timescale 1ns / 1ps

module modular_subtractor_tb();

    reg clk = 0;
    reg [29:0]a;
    reg [29:0]b;
    wire [29:0]c;
    
    modular_subtractor #12 ms(clk, a, b, c);
    
    always #50 clk = ~clk;
    
    initial
    begin
        b = 1063321600;
        a = 1;
        #100;
        b = 1063452672;
        #100;
        b = 1064697856;
        #100;
        b = 1065484288;
        #100;
        b = 1065811968;
        #100; 
        b = 1068236800;
        #100;
        b = 1068433408;
        #100;
        b = 1068564480;
        #100;
        b = 1069219840;
        #100;
        b = 1070727168;
        #100;
        b = 1071513600;
        #100;
        b = 1072496640;
        #100;
        b = 1073479680;
        #100;
        a = 0;
        b = 0;
        #100;
        a = 100;
        b = 23;
        #100;
        a = 9354;
        b = 1239384;
        #100;
    end

endmodule
