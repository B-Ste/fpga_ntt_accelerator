`timescale 1ns / 1ps

module nwc_top #(
    parameter MOD_INDEX = 0,
    parameter LOG_CORE_COUNT = 3)(
    input clk, 
    input start,

    // interface input-RAM 0
    output [10:0]addr0,
    input [63:0]data_in0,

    // interface input-RAM 1
    output [10:0]addr1,
    input [63:0]data_in1,

    //interface output-RAM
    output [10:0]addrw,
    output [63:0]data_out,
    output [3:0]out_wen,
    output reg done = 0
    );

    reg processor_start[2:0];
    reg processor_wen[2:0];

    initial begin
        processor_start[0] = 0;
        processor_start[1] = 0;
        processor_start[2] = 0;
        processor_wen[0] = 0;
        processor_wen[1] = 0;
        processor_wen[2] = 0;
    end

    always @(posedge clk) begin
        processor_start[1] <= processor_start[0];
        processor_start[2] <= processor_start[1];
        processor_wen[1] <= processor_wen[0];
        processor_wen[2] <= processor_wen[1];
    end

    wire [59:0]processor_data_out;

    nwc_processor #(.MOD_INDEX(MOD_INDEX), .LOG_CORE_COUNT(LOG_CORE_COUNT)) nwc_processor (
        .clk(clk),
        .data_in0(data_in0[59:0]),
        .data_in1(data_in1[59:0]),
        .write_enable(processor_wen[2]),
        .start(processor_start[2]),
        .data_out(processor_data_out),
        .output_active(output_active)
        );

    assign data_out = {2'd0, processor_data_out[59:32], 2'd0, processor_data_out[31:0]};

    reg [10:0]addrr_reg;
    reg [10:0]addrw_reg;

    initial begin
        addrr_reg <= 0;
        addrw_reg <= 0;
    end

    assign addr0 = addrr_reg;
    assign addr1 = addrr_reg;
    assign addrw = addrw_reg;
    assign out_wen = output_active ? 4'b1111 : 0; 

    reg input_state = 0;
    always @(posedge clk) begin
        case (input_state)
            0 : begin
                addrr_reg <= 0;
                processor_start[0] <= 0;
                if (start) begin
                    input_state <= 1;
                    processor_wen[0] <= 1;
                end else begin
                    processor_wen[0] <= 0;
                end
            end 
            1 : begin
                addrr_reg <= addrr_reg + 1;
                if (addrr_reg == 2047) begin
                    processor_wen[0] <= 0;
                    processor_start[0] <= 1;
                    input_state <= 0;
                end else begin
                    processor_wen[0] <= 1;
                end
            end
        endcase    
    end

    always @(posedge clk) begin
        if (output_active) begin
            addrw_reg <= addrw_reg + 1;
            done <= 0;
        end else begin
            addrw_reg <= 0;
        end
        if (addrw_reg == 2047) begin
            done <= 1;
        end
    end

endmodule
