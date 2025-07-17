`timescale 1ns / 1ps

module nwc_top #(
    parameter MOD_INDEX = 0,
    parameter LOG_CORE_COUNT = 3)(
    input clk, 
    input start,
    output [10:0]addrr,
    input [31:0]data_in0_up,
    input [31:0]data_in0_down,
    input [31:0]data_in1_up,
    input [31:0]data_in1_down,
    output [10:0]addrw,
    output [31:0]data_out_up,
    output [31:0]data_out_down,
    output [3:0]out_wen,
    output reg done = 0,
    output ready
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

    wire [59:0]processor_data_out, data_in0, data_in1;
    wire processor_ready;
    
    assign data_in0 = {data_in0_down[29:0], data_in0_up[29:0]};
    assign data_in1 = {data_in1_down[29:0], data_in1_up[29:0]};

    nwc_processor #(.MOD_INDEX(MOD_INDEX), .LOG_CORE_COUNT(LOG_CORE_COUNT)) nwc_processor (
        .clk(clk),
        .data_in0(data_in0[59:0]),
        .data_in1(data_in1[59:0]),
        .write_enable(processor_wen[2]),
        .start(processor_start[2]),
        .data_out(processor_data_out),
        .output_active(output_active),
        .ready(processor_ready)
        );

    assign data_out_up = {2'd0, processor_data_out[29:0]};
    assign data_out_down = {2'd0, processor_data_out[59:32]};

    reg [10:0]addrr_reg;
    reg [10:0]addrw_reg;

    initial begin
        addrr_reg <= 0;
        addrw_reg <= 0;
    end

    assign addrr = addrr_reg;
    assign addrw = addrw_reg;
    assign out_wen = output_active ? 4'b1111 : 0; 

    reg input_state = 0;

    assign ready = (processor_ready && (input_state == 0));

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
