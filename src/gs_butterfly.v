module gs_butterfly (
    input clk,
    input [29:0]A,
    input [29:0]B,
    input [29:0]w,
    output [29:0]a,
    output [29:0]b);

    parameter mod_index = 0;

    wire [29:0]sub_out;
    wire [29:0]add_out;
    reg [29:0]add_pipe[8:0];
    reg [29:0]w_pipe[1:0];

    modular_adder #mod_index adder(
        .clk(clk), 
        .a(A), 
        .b(B), 
        .c(add_out));

    modular_subtractor #mod_index sub(
        .clk(clk), 
        .a(A),
        .b(B), 
        .c(sub_out));

    modular_multiplier #mod_index mult (
        .clk(clk),
        .a(sub_out),
        .b(w_pipe[1]),
        .c(b));

    assign a = add_pipe[8];
    integer i;
    always @(posedge clk) begin
        for (i = 0; i < 8; i = i + 1) begin
            add_pipe[i + 1] <= add_pipe[i];
        end
        add_pipe[0] <= add_out;
        w_pipe[0] <= w;
        w_pipe[1] <= w_pipe[0];
    end
    
endmodule