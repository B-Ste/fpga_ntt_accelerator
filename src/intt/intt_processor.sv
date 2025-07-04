`timescale 1ns / 1ps

module intt_processor #(
    parameter MOD_INDEX = 0,
    parameter LOG_CORE_COUNT = 4 ) (
        input clk,
        input start,
        input [59:0]data_in[(1 << LOG_CORE_COUNT) - 1:0][1:0],
        output [59:0]out[(1 << LOG_CORE_COUNT) - 1:0][1:0],
        output [8:0]address_out
    );

    reg [3:0]log_m, log_t;
    reg [9:0]upper_i, lower_i;
    reg [8:0]upper_read_address, lower_read_address;
    reg write_enable, write_select, read_select, input_select;
    reg [1:0]mode;

    // pipeline delay to enable writing to the brams only when valid values are present
    localparam WRITE_PIPE_STAGES = 10;
    reg write_enable_pipe[WRITE_PIPE_STAGES:0];
    reg write_select_pipe[WRITE_PIPE_STAGES:0];

    integer f;
    always @(posedge clk) begin
        write_enable_pipe[0] <= write_enable;
        write_select_pipe[0] <= write_select;

        for (f = 0; f < WRITE_ENABLE_PIPE_STAGES; f = f + 1) begin
            write_enable_pipe[f + 1] <= write_enable_pipe[f];
            write_select_pipe[f + 1] <= write_select_pipe[f];
        end
    end

    reg [29:0]core_output[(1 << LOG_CORE_COUNT) - 1:0][3:0];
    reg [8:0]upper_write_address, lower_write_address;
    reg [59:0]core_input[(1 << LOG_CORE_COUNT) - 1:0][1:0];

    localparam LOG_N = 12;
    localparam ALG_FIRST_STAGE = 2'd0;
    localparam ALG_SECOND_STAGE = 2'd1;
    localparam ALG_THIRD_STAGE = 2'd2;
    localparam STANDBY = 2'd3;

    // main logic for algorithm
    integer j2;
    always @(posedge clk) begin
        case (mode)
            ALG_FIRST_STAGE: begin
                if (upper_read_address == j2) begin
                    // switch to second part of algorithm
                    mode <= ALG_SECOND_STAGE;
                    log_m <= log_m - 1;
                    log_t <= log_t + 1;
                    write_select <= ~write_select;
                    input_select <= 0;
                    upper_read_address <= 0;
                    lower_read_address <= 1;
                    j2 <= 0;
                end else begin
                    upper_read_address <= upper_read_address + 1;
                    lower_read_address <= lower_read_address + 1;
                end
            end
            ALG_SECOND_STAGE: begin
                if (upper_read_address == j2) begin
                    if (upper_i == ((1 << (log_m - 2 - LOG_CORE_COUNT)) - 1)) begin
                        log_m <= log_m - 1;
                        lot_t <= log_t + 1;
                        read_select <= ~read_select;
                        write_select <= ~write_select;
                        if (log_t == LOG_N - 2 - LOG_CORE_COUNT) begin
                            // switch to third part of algorithm
                            mode <= ALG_THIRD_STAGE;
                            upper_read_address <= 0;
                            lower_read_address <= 0;
                            j2 <= (1 << (LOG_N - 2 - LOG_CORE_COUNT));
                        end else begin
                            // stay in part two, but start i loop new
                            upper_i <= 0;
                            upper_read_address <= 0;
                            j2 <= (1 << (log_t + 1)) - 1;
                            lower_i <= 1;
                            lower_read_address <= 1 << (log_t + 1);
                        end
                    end else begin
                        if (lower_i == ((1 << (log_m - 2 - LOG_CORE_COUNT)) - 1)) begin
                            // switch parity of i's
                            upper_i <= 1;
                            upper_read_address <= 1 << log_t;
                            j2 <= (1 << (log_t + 1)) - 1;
                            lower_i <= 0;
                            lower_read_address <= 0;
                        end else begin
                            // increase i's
                            upper_i <= upper_i + 2;
                            upper_read_address <= (upper_i + 2) << log_t;
                            j2 <= ((upper_i + 2) << log_t) + (1 << log_t) - 1;
                            lower_i <= lower_i + 2;
                            lower_read_address <= (lower_i + 2) << log_t;
                        end
                    end
                end else begin
                    upper_read_address <= upper_read_address + 1;
                    lower_read_address <= lower_read_address + 1;
                end
            end
            ALG_THIRD_STAGE: begin
                if (upper_read_address == j2) begin
                    if (log_m == 1) begin
                        mode <= STANDBY;
                        write_enable <= 0;
                        // algorithm is finished
                    end else begin
                        // continue with new m and t
                        log_m <= log_m - 1;
                        log_t <= log_t + 1;
                        upper_read_address <= 0;
                        lower_read_address <= 0;
                        read_select <= ~read_select;
                        write_select <= ~write_select;
                    end
                end else begin
                    upper_read_address <= upper_read_address + 1;
                    lower_read_address <= lower_read_address + 1;
                end
            end
            STANDBY: begin
                if (start) begin
                    mode <= ALG_FIRST_STAGE;
                    log_m <= 12;
                    log_t <= -1;
                    upper_i <= 0;
                    lower_i <= 1;
                    upper_read_address <= 0;
                    lower_read_address <= 0;
                    read_select <= 0;
                    write_select <= 0;
                    input_select <= 1;
                    j2 <= (1 << (LOG_N - 2 - LOG_CORE_COUNT)) - 1;
                end
            end
        endcase
    end

    genvar k;
    generate
        for (k = 0; k < (1 << LOG_CORE_COUNT); k = k + 1) begin
            intt_core #(.MOD_INDEX(MOD_INDEX), .CORE_INDEX(k), .LOG_CORE_COUNT(LOG_CORE_COUNT)) core (
                .clk(clk),
                .log_m(log_m),
                .upper_i(upper_i),
                .lower_i(lower_i),
                .upper_read_address(upper_read_address),
                .lower_read_address(lower_read_address),
                .write_enable(write_enable),
                .write_select(write_select_pipe[WRITE_PIPE_STAGES]),
                .read_select(read_select),
                .input_select(input_select),
                .mode(mode),
                .upper_write_address(upper_write_address),
                .upper_data_input(core_input[k][0]),
                .upper_direct_input(data_in[k][0]),
                .lower_write_address(lower_write_address),
                .lower_data_input(core_input[k][1]),
                .lower_direct_input(data_in[k][1]),
                .r1(core_output[k][0]),
                .r2(core_output[k][1]),
                .r3(core_output[k][2]),
                .r4(core_output[k][3])
            );
        end
    endgenerate

    // pipeline delay to feed router correct values
    localparam ROUTER_INPUT_PIPE_STAGES = 7;

    reg [3:0]log_m_pipe[ROUTER_INPUT_PIPE_STAGES:0];
    reg [3:0]log_t_pipe[ROUTER_INPUT_PIPE_STAGES:0];
    reg [8:0]upper_read_address_pipe[ROUTER_INPUT_PIPE_STAGES:0];
    reg [8:0]lower_read_address_pipe[ROUTER_INPUT_PIPE_STAGES:0];

    always @(posedge clk) begin
        log_m_pipe[0] <= log_m;
        log_t_pipe[0] <= log_t;
        upper_read_address_pipe[0] <= upper_read_address;
        lower_read_address_pipe[0] <= lower_read_address;

        for (f = 0; f < ROUTER_INPUT_PIPE_STAGES; f = f + 1) begin
            log_m_pipe[f + 1] <= log_m_pipe[f];
            log_t_pipe[f + 1] <= log_t_pipe[f];
            upper_read_address_pipe[f + 1] <= upper_read_address_pipe[f];
            lower_read_address_pipe[f + 1] <= lower_read_address_pipe[f];
        end
    end

    intt_router #(.LOG_CORE_COUNT(LOG_CORE_COUNT)) router (
        .clk(clk),
        .log_m(log_m_pipe[ROUTER_INPUT_PIPE_STAGES]),
        .log_t(log_t_pipe[ROUTER_INPUT_PIPE_STAGES]),
        .address_in('{upper_read_address_pipe[ROUTER_INPUT_PIPE_STAGES], lower_read_address_pipe[ROUTER_INPUT_PIPE_STAGES]}),
        .in(core_output),
        .loop(core_input),
        .address_loop('{upper_write_address, lower_write_address}),
        .out(out),
        .address_out(address_out)
    );

endmodule
