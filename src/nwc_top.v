`timescale 1ns / 1ps

module nwc_top(
    input clk, 
    input [59:0]data_in0,
    input [59:0]data_in1,
    input write_enable,
    input start,
    output [59:0]data_out,
    output output_active
    );

    nwc_processor nwc_processor(
        .clk(clk),
        .data_in0(data_in0),
        .data_in1(data_in1),
        .write_enable(write_enable),
        .start(start),
        .data_out(data_out),
        .output_active(output_active)
        );
endmodule
