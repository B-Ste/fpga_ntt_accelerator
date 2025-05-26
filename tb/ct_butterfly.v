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
        #1300;    
    end

endmodule