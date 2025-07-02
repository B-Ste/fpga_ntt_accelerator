module gs_butterfly (
    input clk,
    input [29:0]A,
    input [29:0]B,
    input [29:0]w,
    output [29:0]a,
    output [29:0]b);

    parameter MOD_INDEX = 0;

    localparam PIPE_STAGES = 3;

    wire [29:0]sub_out;
    wire [29:0]add_out;
    reg [29:0]add_pipe[PIPE_STAGES:0];
    reg [29:0]w_pipe[1:0];

    modular_adder #MOD_INDEX adder(
        .clk(clk), 
        .a(A), 
        .b(B), 
        .c(add_out));

    modular_subtractor #MOD_INDEX sub(
        .clk(clk), 
        .a(A),
        .b(B), 
        .c(sub_out));

    modular_multiplier #MOD_INDEX mult (
        .clk(clk),
        .a(sub_out),
        .b(w_pipe[1]),
        .c(b));

    assign a = add_pipe[PIPE_STAGES];
    integer i;
    always @(posedge clk) begin
        for (i = 0; i < PIPE_STAGES; i = i + 1) begin
            add_pipe[i + 1] <= add_pipe[i];
        end
        add_pipe[0] <= add_out;
        w_pipe[0] <= w;
        w_pipe[1] <= w_pipe[0];
    end
    
endmodule