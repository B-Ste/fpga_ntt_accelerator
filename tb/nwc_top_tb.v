`timescale 1ns / 1ps

module nwc_top_tb ();

    reg clk = 0;
    reg start;
    reg [31:0]data_in0_up, data_in0_down, data_in1_up, data_in1_down;
    wire [12:0]addrr, addrw;
    wire [31:0]data_out_up, data_out_down;
    wire [3:0]out_wen;
    wire done, ready, memory_writable;

    nwc_top dut (
        .clk(clk), 
        .start(start),
        .addrr(addrr),
        .data_in0_up(data_in0_up),
        .data_in0_down(data_in0_down),
        .data_in1_up(data_in1_up),
        .data_in1_down(data_in1_down),
        .addrw(addrw),
        .data_out_up(data_out_up),
        .data_out_down(data_out_down),
        .out_wen(out_wen),
        .output_ready(done),
        .start_ready(ready),
        .memory_writable(memory_writable)
    );

    always #50 clk = ~clk;

    initial begin
        start = 0;
        #100;
        start = 1;
        #100;
        start = 0;
    end

    always @(posedge clk) begin
        data_in0_up <= addrr >> 2;
        data_in0_down <= (addrr >> 2) + 2048;
        data_in1_up <= addrr >> 2;
        data_in1_down <= (addrr >> 2) + 2048;
    end
    
endmodule