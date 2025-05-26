module ct_butterfly (
    input clk,
    input [29:0]a,
    input [29:0]b,
    input [29:0]w,
    output [29:0]A,
    output [29:0]B);

    parameter mod_index = 0;

    wire [29:0] mult_out;

    modular_multiplier #mod_index mult (
        .clk(clk),
        .a(w),
        .b(b),
        .c(mult_out)
    );

    modular_adder #mod_index adder(
        .clk(clk), 
        .a(a), 
        .b(mult_out), 
        .c(A)
    );

    modular_subtractor #mod_index sub(
        .clk(clk), 
        .a(a),
        .b(mult_out), 
        .c(B));
    
endmodule