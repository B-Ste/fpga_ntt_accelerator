`timescale 1ns / 1ps

module intt_processor #(
    parameter MOD_INDEX = 0,
    parameter LOG_CORE_COUNT = 4 ) (
        input clk,
        input start,
        input [59:0]data_in[(1 << LOG_CORE_COUNT) - 1:0][1:0],
        output [59:0]out[(1 << LOG_CORE_COUNT) - 1:0][1:0],
        output [8:0]address_out,
        output output_active
    );

    reg [3:0]log_m, log_t;
    reg [9:0]upper_i, lower_i;
    reg [8:0]upper_read_address, lower_read_address;
    reg write_enable, write_select, read_select, input_select;
    reg [1:0]mode = STANDBY;

    localparam PIPE_STAGES = 11;

    // pipeline delay to wait for valid output
    localparam OA_STAGES = PIPE_STAGES;
    reg output_active_pipe[OA_STAGES:0];
    assign output_active = output_active_pipe[OA_STAGES];

    integer f;
    always @(posedge clk) begin
        for (f = 0; f < OA_STAGES; f = f + 1) begin
            output_active_pipe[f + 1] <= output_active_pipe[f];
        end
    end

    // pipeline delay to enable writing to the brams only when valid values are present
    localparam WRITE_PIPE_STAGES = PIPE_STAGES - 4;
    reg write_enable_pipe[WRITE_PIPE_STAGES:0];
    reg write_select_pipe[WRITE_PIPE_STAGES:0];

    always @(posedge clk) begin
        write_enable_pipe[0] <= write_enable;
        write_select_pipe[0] <= write_select;

        for (f = 0; f < WRITE_PIPE_STAGES; f = f + 1) begin
            write_enable_pipe[f + 1] <= write_enable_pipe[f];
            write_select_pipe[f + 1] <= write_select_pipe[f];
        end
    end

    reg [29:0]core_output[(1 << LOG_CORE_COUNT) - 1:0][3:0];
    reg [8:0]write_address[1:0];
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
                    if (upper_i == ((1 << (log_m - 1 - LOG_CORE_COUNT)) - 1)) begin
                        log_m <= log_m - 1;
                        log_t <= log_t + 1;
                        read_select <= ~read_select;
                        write_select <= ~write_select;
                        if ((log_t + 1) == (LOG_N - 2 - LOG_CORE_COUNT)) begin
                            // switch to third part of algorithm
                            mode <= ALG_THIRD_STAGE;
                            upper_read_address <= 0;
                            lower_read_address <= 0;
                            j2 <= (1 << (LOG_N - 2 - LOG_CORE_COUNT)) - 1;
                        end else begin
                            // stay in part two, but start i loop new
                            upper_i <= 0;
                            upper_read_address <= 0;
                            j2 <= (1 << (log_t + 1)) - 1;
                            lower_i <= 1;
                            lower_read_address <= 1 << (log_t + 1);
                        end
                    end else begin
                        if (lower_i == ((1 << (log_m - 1 - LOG_CORE_COUNT)) - 1)) begin
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
                    if (log_m == 1) output_active_pipe[0] <= 1;
                    upper_read_address <= upper_read_address + 1;
                    lower_read_address <= lower_read_address + 1;
                end
            end
            STANDBY: begin
                output_active_pipe[0] <= 0;
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
                    write_enable <= 1;
                    input_select <= 1;
                    j2 <= (1 << (LOG_N - 2 - LOG_CORE_COUNT)) - 1;
                end
            end
        endcase
    end

    wire [59:0]router_out[(1 << LOG_CORE_COUNT) - 1:0][1:0];
    wire [29:0]n_neg;

    generate
        case (MOD_INDEX)
            0 : assign n_neg = 1063062001;
            1 : assign n_neg = 1063193041;
            2 : assign n_neg = 1064437921;
            3 : assign n_neg = 1065224161;
            4 : assign n_neg = 1065551761;
            5 : assign n_neg = 1067976001;
            6 : assign n_neg = 1068172561;
            7 : assign n_neg = 1068303601;
            8 : assign n_neg = 1068958801;
            9 : assign n_neg = 1070465761;
            10: assign n_neg = 1071252001;
            11: assign n_neg = 1072234801;
            12: assign n_neg = 1073217601;
        endcase
    endgenerate

    genvar k;
    generate
        for (k = 0; k < (1 << LOG_CORE_COUNT); k = k + 1) begin
            if ((k % 2) == 0) begin
                intt_core #(.MOD_INDEX(MOD_INDEX), .CORE_INDEX(k), .LOG_CORE_COUNT(LOG_CORE_COUNT)) core (
                .clk(clk),
                .log_m(log_m),
                .upper_i(upper_i),
                .lower_i(lower_i),
                .upper_read_address(upper_read_address),
                .lower_read_address(lower_read_address),
                .write_enable(write_enable_pipe[WRITE_PIPE_STAGES]),
                .write_select(write_select_pipe[WRITE_PIPE_STAGES]),
                .read_select(read_select),
                .input_select(input_select),
                .mode(mode),
                .upper_write_address(write_address[0]),
                .upper_data_input(core_input[k][0]),
                .upper_direct_input(data_in[k][0]),
                .lower_write_address(write_address[0]),
                .lower_data_input(core_input[k][1]),
                .lower_direct_input(data_in[k][1]),
                .r1(core_output[k][0]),
                .r2(core_output[k][1]),
                .r3(core_output[k][2]),
                .r4(core_output[k][3])
            );
            end else begin
                intt_core #(.MOD_INDEX(MOD_INDEX), .CORE_INDEX(k), .LOG_CORE_COUNT(LOG_CORE_COUNT)) core (
                .clk(clk),
                .log_m(log_m),
                .upper_i(upper_i),
                .lower_i(lower_i),
                .upper_read_address(upper_read_address),
                .lower_read_address(lower_read_address),
                .write_enable(write_enable_pipe[WRITE_PIPE_STAGES]),
                .write_select(write_select_pipe[WRITE_PIPE_STAGES]),
                .read_select(read_select),
                .input_select(input_select),
                .mode(mode),
                .upper_write_address(write_address[1]),
                .upper_data_input(core_input[k][0]),
                .upper_direct_input(data_in[k][0]),
                .lower_write_address(write_address[1]),
                .lower_data_input(core_input[k][1]),
                .lower_direct_input(data_in[k][1]),
                .r1(core_output[k][0]),
                .r2(core_output[k][1]),
                .r3(core_output[k][2]),
                .r4(core_output[k][3])
            );
            end

            modular_multiplier #(.MOD_INDEX(MOD_INDEX)) m1 (
                .clk(clk), 
                .a(router_out[k][0][29:0]), 
                .b(n_neg), 
                .c(out[k][0][29:0])
            );

            modular_multiplier #(.MOD_INDEX(MOD_INDEX)) m2 (
                .clk(clk), 
                .a(router_out[k][0][59:30]), 
                .b(n_neg), 
                .c(out[k][0][59:30])
            );

            modular_multiplier #(.MOD_INDEX(MOD_INDEX)) m3 (
                .clk(clk), 
                .a(router_out[k][1][29:0]), 
                .b(n_neg), 
                .c(out[k][1][29:0])
            );

            modular_multiplier #(.MOD_INDEX(MOD_INDEX)) m4 (
                .clk(clk), 
                .a(router_out[k][1][59:30]), 
                .b(n_neg), 
                .c(out[k][1][59:30])
            );
        end
    endgenerate

    // pipeline delay to feed router correct values
    localparam ROUTER_INPUT_PIPE_STAGES = PIPE_STAGES - 5;
    reg [3:0]log_m_pipe[ROUTER_INPUT_PIPE_STAGES + 1:0];
    reg [3:0]log_t_pipe[ROUTER_INPUT_PIPE_STAGES + 1:0];
    reg [8:0]upper_read_address_pipe[ROUTER_INPUT_PIPE_STAGES + 1:0];
    reg [8:0]lower_read_address_pipe[ROUTER_INPUT_PIPE_STAGES + 1:0];

    // pipeline delay to wait for last multiplication before outputting addresses
    localparam ADDRESS_OUT_PIPE_STAGES = 4;
    wire [8:0]router_address_out;
    reg [8:0]address_out_pipe[ADDRESS_OUT_PIPE_STAGES:0];
    assign address_out = address_out_pipe[ADDRESS_OUT_PIPE_STAGES];

    always @(posedge clk) begin
        log_m_pipe[0] <= log_m;
        log_t_pipe[0] <= log_t;
        upper_read_address_pipe[0] <= upper_read_address;
        lower_read_address_pipe[0] <= lower_read_address;

        for (f = 0; f < ROUTER_INPUT_PIPE_STAGES + 1; f = f + 1) begin
            log_m_pipe[f + 1] <= log_m_pipe[f];
            log_t_pipe[f + 1] <= log_t_pipe[f];
            upper_read_address_pipe[f + 1] <= upper_read_address_pipe[f];
            lower_read_address_pipe[f + 1] <= lower_read_address_pipe[f];
        end

        address_out_pipe[0] <= router_address_out;
        for (f = 0; f < ADDRESS_OUT_PIPE_STAGES; f = f + 1) begin
            address_out_pipe[f + 1] <= address_out_pipe[f];
        end
    end

    intt_router #(.LOG_CORE_COUNT(LOG_CORE_COUNT)) router (
        .clk(clk),
        .log_m(log_m_pipe[ROUTER_INPUT_PIPE_STAGES]),
        .log_t(log_t_pipe[ROUTER_INPUT_PIPE_STAGES]),
        .address_in('{lower_read_address_pipe[ROUTER_INPUT_PIPE_STAGES], upper_read_address_pipe[ROUTER_INPUT_PIPE_STAGES]}),
        .in(core_output),
        .loop(core_input),
        .address_loop(write_address),
        .out(router_out),
        .address_out(router_address_out)
    );

    /*
    integer fd;
    integer r;
    reg [8 * 100:0]str;

    initial begin
        fd = $fopen("tracing.txt", "w");
        $fclose(fd);
    end

    always @(posedge clk) begin
        if (mode != STANDBY || output_active) begin
            fd = $fopen("tracing.txt", "a");
            for (r = 0; r < (1 << LOG_CORE_COUNT); r = r + 1) begin
                $sformat(str, "m=%0d j=%0d k=%0d r1=%0d", (1 << log_m_pipe[ROUTER_INPUT_PIPE_STAGES]), upper_read_address_pipe[ROUTER_INPUT_PIPE_STAGES], r, core_output[r][0]);
                $fdisplay(fd, "%0s", str);
                $sformat(str, "m=%0d j=%0d k=%0d r2=%0d", (1 << log_m_pipe[ROUTER_INPUT_PIPE_STAGES]), upper_read_address_pipe[ROUTER_INPUT_PIPE_STAGES], r, core_output[r][1]);
                $fdisplay(fd, "%0s", str);
                $sformat(str, "m=%0d j=%0d k=%0d r3=%0d", (1 << log_m_pipe[ROUTER_INPUT_PIPE_STAGES]), lower_read_address_pipe[ROUTER_INPUT_PIPE_STAGES], r, core_output[r][2]);
                $fdisplay(fd, "%0s", str);
                $sformat(str, "m=%0d j=%0d k=%0d r4=%0d", (1 << log_m_pipe[ROUTER_INPUT_PIPE_STAGES]), lower_read_address_pipe[ROUTER_INPUT_PIPE_STAGES], r, core_output[r][3]);
                $fdisplay(fd, "%0s", str);
            end
            $fclose(fd);
        end
    end

    initial begin
        fd = $fopen("input.txt", "w");
        $fclose(fd);
    end

    integer fd_in;
    always @(posedge clk) begin
        if (mode != STANDBY) begin
            fd_in = $fopen("input.txt", "a");
            for (r = 0; r < (1 << LOG_CORE_COUNT); r = r + 1) begin
                $sformat(str, "m=%0d j=%0d k=%0d r1=%0d", (1 << log_m_pipe[ROUTER_INPUT_PIPE_STAGES - 3]), router_address_loop[0], r, router_loop[f][0]);
                $fdisplay(fd_in, "%0s", str);
                $sformat(str, "m=%0d j=%0d k=%0d r2=%0d", (1 << log_m_pipe[ROUTER_INPUT_PIPE_STAGES - 3]), router_address_loop[1], r, router_loop[f][1]);
                $fdisplay(fd_in, "%0s", str);
            end
            $fclose(fd_in);
        end
    end*/

endmodule
