`timescale 1ns/1ps

module modular_multiplier_tb ();

    reg clk = 0;
    reg [29:0]a1, a2, a3;
    reg [29:0]b1, b2, b3;
    wire [29:0]c1, c2, c3;

    modular_multiplier #0 m1 (clk, a1, b1, c1);
    modular_multiplier #8 m2 (clk, a2, b2, c2);
    modular_multiplier #12 m3 (clk, a3, b3, c3);

    always #50 clk = ~clk;

    initial
    begin
        a1 = 0;
        b1 = 10;
        a2 = 0;
        b2 = 10;
        a3 = 0;
        b3 = 10;
        #100;
        a1 = 1063321600;
        b1 = 1;
        a2 = 1069219840;
        b2 = 1;
        a3 = 1073479680;
        b3 = 1;
        #100;
        a1 = 1063321600;
        b1 = 2;
        a2 = 1069219840;
        b2 = 2;
        a3 = 1073479680;
        b3 = 2;
        #100;
        a1 = 1063321600;
        b1 = 1063321600;
        a2 = 1069219840;
        b2 = 1069219840;
        a3 = 1073479680;
        b3 = 1073479680;
        #100;
        a1 = 90;
        b1 = 30;
        a2 = 450;
        b2 = 74;
        a3 = 23;
        b3 = 98;
        #100;
        a1 = 40;
        b1 = 23;
        a2 = 12;
        b2 = 58;
        a3 = 983;
        b3 = 329;
        #100;
        a1 = 56789;
        b1 = 1234789;
        a2 = 1859;
        b2 = 9467819;
        a3 = 57169;
        b3 = 9278165;
    end
    
endmodule
