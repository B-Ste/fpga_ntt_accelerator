`timescale 1ns / 1ps

module nwc_top_tb ();

    reg clk = 0;
    reg start;
    reg [63:0]data_in0, data_in1;
    wire [10:0]addr0, addr1, addrw;
    wire [63:0]data_out;
    wire [7:0]out_wen;
    wire done;

    nwc_top dut (
        .clk(clk), 
        .start(start),
        .addr0(addr0),
        .data_in0(data_in0),
        .addr1(addr1),
        .data_in1(data_in1),
        .addrw(addrw),
        .data_out(data_out),
        .out_wen(out_wen),
        .done(done)
    );

    always #50 clk = ~clk;

    initial begin
        start = 1;
        #100;
        start = 0;
    end

    reg [63:0]data_reg;
    always @(posedge clk) begin
        data_reg <= addr0;
        data_in0 <= data_reg;
        data_in1 <= data_reg;
    end
    
endmodule