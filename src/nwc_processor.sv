`timescale 1ns / 1ps

module nwc_processor #(
    parameter MOD_INDEX = 0,
    parameter LOG_CORE_COUNT = 3)(
    input clk,
    input [59:0]data_in0,
    input [59:0]data_in1,
    input write_enable,
    input start,
    output reg [59:0]data_out,
    output output_active,
    output ready,
    output computation_finished
    );

    // generate write addresses for ntt processors to save on input ports
    reg [10:0]address_in = 0;
    always @(posedge clk) begin
        if (write_enable) begin
            address_in <= address_in + 1;
        end
    end

    // NTT processor 0
    wire output_active0;
    wire [59:0]out0[(1 << LOG_CORE_COUNT) - 1:0][1:0];
    wire [(9 - LOG_CORE_COUNT):0]address_out0;
    ntt_processor #(.MOD_INDEX(MOD_INDEX), .LOG_CORE_COUNT(LOG_CORE_COUNT)) ntt0 (
        .clk(clk),
        .write_enable(write_enable),
        .start(start),
        .address_in(address_in),
        .data_in(data_in0),
        .output_active(output_active0),
        .out(out0),
        .address_out(address_out0),
        .ready(ready)
    );

    // NTT processor 1
    wire output_active1, ready1;
    wire [59:0]out1[(1 << LOG_CORE_COUNT) - 1:0][1:0];
    wire [(9 - LOG_CORE_COUNT):0]address_out1;
    ntt_processor #(.MOD_INDEX(MOD_INDEX), .LOG_CORE_COUNT(LOG_CORE_COUNT)) ntt1 (
        .clk(clk),
        .write_enable(write_enable),
        .start(start),
        .address_in(address_in),
        .data_in(data_in1),
        .output_active(output_active1),
        .out(out1),
        .address_out(address_out1),
        .ready(ready1)
    );

    // multiplier array
    reg [59:0]intt_in[(1 << LOG_CORE_COUNT) - 1:0][1:0];

    genvar k;
    generate
        for (k = 0; k < (1 << LOG_CORE_COUNT); k = k + 1) begin
            modular_multiplier #(.MOD_INDEX(MOD_INDEX)) m1 (
                .clk(clk), 
                .a(out0[k][0][29:0]), 
                .b(out1[k][0][29:0]), 
                .c(intt_in[k][0][29:0])
            );

            modular_multiplier #(.MOD_INDEX(MOD_INDEX)) m2 (
                .clk(clk), 
                .a(out0[k][0][59:30]), 
                .b(out1[k][0][59:30]), 
                .c(intt_in[k][0][59:30])
            );

            modular_multiplier #(.MOD_INDEX(MOD_INDEX)) m3 (
                .clk(clk), 
                .a(out0[k][1][29:0]), 
                .b(out1[k][1][29:0]), 
                .c(intt_in[k][1][29:0])
            );

            modular_multiplier #(.MOD_INDEX(MOD_INDEX)) m4 (
                .clk(clk), 
                .a(out0[k][1][59:30]), 
                .b(out1[k][1][59:30]), 
                .c(intt_in[k][1][59:30])
            );
        end
    endgenerate

    // INTT processor with input signal controls
    wire intt_start;
    wire [59:0]intt_out[(1 << LOG_CORE_COUNT) - 1:0][1:0];
    wire [(9 - LOG_CORE_COUNT):0]intt_address_out;
    wire intt_output_active;
    reg computation_finished_state = 0;
    reg computation_finished_reg = 0;

    assign computation_finished = computation_finished_reg;

    always @(posedge clk) begin
        case (computation_finished_state)
            0 : begin
                computation_finished_reg <= 0;
                if (intt_output_active == 1) begin
                    computation_finished_state <= 1;
                end
            end
            1 : begin
                if (intt_output_active == 0) begin
                    computation_finished_reg <= 1;
                    computation_finished_state <= 0;
                end
            end 
        endcase
    end

    // delay start signal to intt processor to account for multiplication
    localparam START_STAGES = 3;
    reg start_pipe[START_STAGES:0];
    assign intt_start = start_pipe[START_STAGES];
    integer f;
    always @(posedge clk) begin
        start_pipe[0] <= output_active0;
        for (f = 0; f < START_STAGES; f = f + 1) begin
            start_pipe[f + 1] <= start_pipe[f];
        end
    end

    intt_processor #(.MOD_INDEX(MOD_INDEX), .LOG_CORE_COUNT(LOG_CORE_COUNT)) intt (
        .clk(clk),
        .start(intt_start),
        .data_in(intt_in),
        .out(intt_out),
        .address_out(intt_address_out),
        .output_active(intt_output_active)
    );

    localparam LOG_N = 12;
    localparam HEIGHT = 1 << (LOG_N - (LOG_CORE_COUNT + 2));

    wire [59:0]output_memory[(1 << LOG_CORE_COUNT) - 1:0][1:0];
    genvar r;
    generate
        for (r = 0; r < (1 << LOG_CORE_COUNT); r = r + 1) begin
            (* ram_style = "block" *) reg [59:0]upper_output_mem[HEIGHT - 1:0];
            (* ram_style = "block" *) reg [59:0]lower_output_mem[HEIGHT - 1:0];

            always @(posedge clk) begin
                upper_output_mem[intt_address_out] <= intt_out[r][0];
            end

            always @(posedge clk) begin
                lower_output_mem[intt_address_out] <= intt_out[r][1];
            end

            assign output_memory[r][0] = upper_output_mem[output_address[(LOG_N - (LOG_CORE_COUNT + 2)) - 1:0]];

            assign output_memory[r][1] = lower_output_mem[output_address[(LOG_N - (LOG_CORE_COUNT + 2)) - 1:0]];
        end
    endgenerate

    // control result output and assign fitting memory contents to data output
    localparam PIPE_STAGES = 3;
    reg [10:0]output_address = 0;
    reg intt_output_active_pipe[PIPE_STAGES:0];
    assign output_active = intt_output_active_pipe[PIPE_STAGES];
    integer c;
    always @(posedge clk) begin
        intt_output_active_pipe[0] <= intt_output_active || (intt_output_active_pipe[0] && (output_address != (2048 - PIPE_STAGES)));
        for (c = 0; c < PIPE_STAGES; c = c + 1) begin
            intt_output_active_pipe[c + 1] <= intt_output_active_pipe[c];
        end
        if (intt_output_active_pipe[PIPE_STAGES - 1] == 1) begin
            for (f = 0; f < (1 << LOG_CORE_COUNT); f = f + 1) begin
                if (f == output_address[9:(9 - LOG_CORE_COUNT + 1)]) begin
                    if (output_address[10] == 0) begin
                        data_out <= output_memory[f][0];
                    end else begin
                        data_out <= output_memory[f][1];
                    end
                end
            end
            output_address <= output_address + 1;
        end
    end

endmodule
