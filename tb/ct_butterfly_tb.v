module ct_butterfly_tb ();
    reg clk = 0;
    reg [29:0] a;
    reg [29:0] b;
    reg [29:0] w;
    wire [29:0] A;
    wire [29:0] B;

    ct_butterfly #12 ct_bf(
        .clk(clk),
        .a(a),
        .b(b),
        .w(w),
        .A(A),
        .B(B)
    );

    always #50 clk = ~clk;

    initial 
    begin
        a = 12345;
        b = 41524;
        w = 95267;
        #100;
        a = 8426;
        b = 37495;
        w = 96324875;
        #100;
        a = 82157;
        b = 9871452;
        w = 91245736;
        #100;
        a = 0;
        b = 0;
        w = 0;
        #1300;    
    end

endmodule