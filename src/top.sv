module top (
    input clk,
    input btn0,
    input btn1,
    input btn2,
    input btn3,
    output reg [1:0] o1,
    output reg [1:0] o2,
    output reg [1:0] o3,
    output reg [1:0] o4
);

    reg i1, i2, i3, i4;
    wire [29:0] t1, t2, t3, t4;
    reg [29:0] a1, a2, a3, a4;
    reg [29:0]in[31:0][3:0];
    reg [59:0]loop[31:0][1:0];
    reg [8:0]address_loop[31:0][1:0];
    reg [59:0]out[31:0][1:0];
    reg [8:0]address_out[31:0];

    ntt_core c (
        .clk(clk),
        .log_m(0),
        .i(0),
        .read_adress(0),
        .write_enable(1),
        .mode(0),
        .upper_write_address({8'd0, i1}),
        .upper_data_input({29'd0, i2}),
        .lower_write_address({8'd0, i3}),
        .lower_data_input({29'd0, i4}),
        .r1(t1),
        .r2(t2),
        .r3(t3),
        .r4(t4));

    integer i;
    always @(posedge clk) begin
        i1 <= btn0;
        i2 <= btn1;
        i3 <= btn2;
        i4 <= btn3;
        a1 <= t1;
        a2 <= t2;
        a3 <= t3;
        a4 <= t4;
        o1 <= {a1[0], a1[7]};
        o2 <= {loop[3][1][0], a2[29]};
        o3 <= {a3[5], address_loop[16][1][7]};
        o4 <= {a4[2], address_out[19][9]};
    end
    
endmodule