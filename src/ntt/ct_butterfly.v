module ct_butterfly (
    input clk,
    input [29:0]a,
    input [29:0]b,
    input [29:0]w,
    output [29:0]A,
    output [29:0]B);

    parameter MOD_INDEX = 0;
    
    localparam PIPE_STAGES = 4;

    wire [29:0]mult_out;
    reg [29:0]pipe[PIPE_STAGES:0];

    modular_multiplier #MOD_INDEX mult (
        .clk(clk),
        .a(w),
        .b(b),
        .c(mult_out));

    modular_adder #MOD_INDEX adder(
        .clk(clk), 
        .a(pipe[PIPE_STAGES]), 
        .b(mult_out), 
        .c(A));

    modular_subtractor #MOD_INDEX sub(
        .clk(clk), 
        .a(pipe[PIPE_STAGES]),
        .b(mult_out), 
        .c(B));

    integer i;
    always @(posedge clk) begin
        for (i = 0; i < PIPE_STAGES; i = i + 1) begin
            pipe[i + 1] <= pipe[i];
        end
        pipe[0] <= a;
    end
    
endmodule