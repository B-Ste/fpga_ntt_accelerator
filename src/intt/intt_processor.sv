`timescale 1ns / 1ps

module intt_processor #(
    parameter MOD_INDEX = 0,
    parameter LOG_CORE_COUNT = 4 ) (
        input clk,
        input [59:0]data_in[(1 << LOG_CORE_COUNT) - 1:0][1:0]
    );

endmodule
