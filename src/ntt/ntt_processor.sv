module ntt_processor #(
    parameter MOD_INDEX = 0,
    parameter LOG_CORE_COUNT = 5) (
        input clk,
        input write_enable,
        input start,
        input [10:0]address_in,
        input [59:0]data_in,
        output reg done,
        output [59:0]out[(1 << LOG_CORE_COUNT) - 1:0][1:0],
        output [8:0]address_out
    );
    
    localparam PIPE_STAGES = 10;
    localparam LOG_N = 12;
    localparam N_4 = 1024;
    localparam ALG_FIRST_STAGE = 2'd0;
    localparam ALG_SECOND_STAGE = 2'd1;
    localparam ALG_THIRD_STAGE = 2'd2;
    localparam STANDBY = 2'd3;

    reg core_write_enable[(1 << LOG_CORE_COUNT) - 1:0][1:0];
    reg [1:0]mode = STANDBY;
    reg [3:0]log_m;
    reg [3:0]log_t;
    reg [9:0]i;
    reg [8:0]even_read_address;
    reg [8:0]odd_read_address; 
    reg [8:0]upper_write_address; 
    reg [8:0]lower_write_address;
    wire [29:0]router_in[(1 << LOG_CORE_COUNT) - 1:0][3:0];
    reg [59:0]core_data_input[(1 << LOG_CORE_COUNT) - 1:0][1:0];
    wire [59:0]router_loop[(1 << LOG_CORE_COUNT) - 1:0][1:0];
    reg [8:0]core_address_input[1:0];
    wire [8:0]router_address_loop[1:0];

    integer pipe_threshold;
    reg [8:0]address_pipe[1:0][PIPE_STAGES - 3 : 0];
    reg [3:0]log_m_pipe[PIPE_STAGES - 3:0];
    reg [3:0]log_t_pipe[PIPE_STAGES - 3:0];
    wire [9:0] i_threshold = ((log_m - LOG_CORE_COUNT) > 0) ? ((1 << (log_m - LOG_CORE_COUNT)) - 1) : 0;
    integer j1, j2;
    integer t;
    always @(posedge clk ) begin
        log_m_pipe[0] <= log_m;
        log_t_pipe[0] <= log_t;
        for (t = 0; t < (PIPE_STAGES - 3); t = t + 1) begin
            log_m_pipe[t + 1] <= log_m_pipe[t];
            log_t_pipe[t + 1] <= log_t_pipe[t];
        end
    
        // enable writing back to memory only when the first new coefficients are through the pipeline.
        pipe_threshold <= pipe_threshold + 1;
        if (pipe_threshold == PIPE_STAGES) begin
            for (t = 0; t < (1 << LOG_CORE_COUNT); t = t + 1) begin
                core_write_enable[t][0] <= 1;
                core_write_enable[t][1] <= 1;
            end 
        end
        
        address_pipe[0][0] <= even_read_address;
        address_pipe[1][0] <= odd_read_address;
        for (t = 0; t < PIPE_STAGES - 3; t = t + 1) begin
            address_pipe[0][t + 1] <= address_pipe[0][t];
            address_pipe[1][t + 1] <= address_pipe[1][t];
        end
        
        // Multiplex core-inputs from outside and from router
        for (t = 0; t < (1 << LOG_CORE_COUNT); t = t + 1) begin
            if (write_enable) begin
                core_data_input[t][0] <= data_in;
                core_data_input[t][1] <= data_in;
            end else begin
                core_data_input[t][0] <= router_loop[t][0];
                core_data_input[t][1] <= router_loop[t][1];
            end
        end
        if (write_enable) begin
            core_address_input[0] <= {{(LOG_CORE_COUNT - 1) {1'd0}}, address_in[(9 - LOG_CORE_COUNT):0]};
            core_address_input[1] <= {{(LOG_CORE_COUNT - 1) {1'd0}}, address_in[(9 - LOG_CORE_COUNT):0]};
        end else begin
            core_address_input[0] <= router_address_loop[0];
            core_address_input[1] <= router_address_loop[1];
        end
       
        // algorithm
        case (mode)
            ALG_FIRST_STAGE: begin
                // Check, if j-loop is at an end
                if (even_read_address == j2) begin
                    log_m <= log_m + 1;
                    log_t <= log_t - 1;
                    // Check if the next loop is in the second part of the algrithm
                    if (log_t - 1 == LOG_N - 2 - LOG_CORE_COUNT) begin
                        // Start second part of algorithm
                        mode <= ALG_SECOND_STAGE;
                        j1 <= 0;
                        j2 <= (1 << (log_t - 1)) - 1;
                        even_read_address <= 0;
                        /* Set start-address of odd-indexed cores into the middle of the [j1, j2]-interval
                        to circumvent memory access conflicts. */
                        odd_read_address <= (1 << (log_t - 2));
                    end else begin
                        // remain in first part of algorithm
                        even_read_address <= 0;
                        odd_read_address <= 0;
                    end
                end else begin
                    // Continue loop in first part of algorithm
                    even_read_address <= even_read_address + 1;
                    odd_read_address <= odd_read_address + 1;
                end
            end
            ALG_SECOND_STAGE: begin
                // Check if j-loop is at an end
                if (even_read_address == j2) begin
                    // Check if i loop is at an end
                    if (i == i_threshold) begin
                        log_m <= log_m + 1;
                        log_t <= log_t - 1;
                        // Check if next loop is in third part of the algorithm
                        if (log_t == 0) begin
                            // Start third part of algorithm
                            mode <= ALG_THIRD_STAGE;
                            j2 <= (1 << (LOG_N - 2 - LOG_CORE_COUNT)) - 1;
                            even_read_address <= 0;
                            odd_read_address <= 0;
                        end else begin
                            // Remain in second part of algorithm and continue with new m and t
                            even_read_address <= 0;
                            odd_read_address <= (1 << (log_t - 1)) - 1;
                        end
                    end else begin
                        // Remain in second part of algorithm and continue with new i, same m and t
                        i <= i + 1;
                        j1 <= (i + 1) << log_t;
                        j2 <= j1 + (1 << log_t) - 1;
                        even_read_address <= j1;
                        odd_read_address <= j1 + (1 << (log_t - 1));
                    end
                end else begin
                    // Contiue loop in second part of algorithm
                    even_read_address <= even_read_address + 1;
                    /* As the odd-indexed cores start in the middle of the [j1, j2]-interval,
                    the odd_read_address must be set to 0 after half of the loop. */
                    if (odd_read_address == j2) odd_read_address <= 0;
                    else odd_read_address <= odd_read_address + 1;
                end
            end
            ALG_THIRD_STAGE: begin
                // Check if j-loop is at an end
                if (even_read_address == j2) begin
                    // Go into standby-mode when ntt is done
                    mode <= STANDBY;
                    done <= 1;
                end else begin
                    // Continue loop
                    even_read_address <= even_read_address + 1;
                    odd_read_address <= odd_read_address + 1;
                end
            end
            STANDBY: begin
                if (start == 1) begin
                    mode <= ALG_FIRST_STAGE;
                    done <= 0;
                    pipe_threshold <= 1;
                    log_m <= 0;
                    log_t <= 10;
                    i <= 0;
                    even_read_address <= 0;
                    odd_read_address <= 0;
                    upper_write_address <= 0;
                    upper_write_address <= 0;
                    pipe_threshold = 0;
                    j1 <= 0;
                    j2 <= (N_4 >> LOG_CORE_COUNT) - 1;
                    for (t = 0; t < (1 << LOG_CORE_COUNT); t = t + 1) begin
                        core_write_enable[t][0] <= 0;
                        core_write_enable[t][1] <= 0;
                    end
                end
                if (write_enable) begin
                    // Only enable writing on the targeted processor
                    for (t = 0; t < (1 << LOG_CORE_COUNT); t = t + 1) begin
                        if (t == address_in[9:(9 - LOG_CORE_COUNT + 1)]) begin
                            if (address_in[10] == 0) begin
                                core_write_enable[t][0] <= 1;
                                core_write_enable[t][1] <= 0;
                            end else begin
                                core_write_enable[t][0] <= 0;
                                core_write_enable[t][1] <= 1;
                            end
                        end else begin
                            core_write_enable[t][0] <= 0;
                            core_write_enable[t][1] <= 0;
                        end
                    end
                end
            end
        endcase
    end

    genvar k;
    generate
        for (k = 0; k < (6'd1 << LOG_CORE_COUNT); k = k + 1) begin
            if ((k & 1) == 0) begin
                ntt_core #(.MOD_INDEX(MOD_INDEX), .CORE_INDEX(k), .LOG_CORE_COUNT(LOG_CORE_COUNT)) core (
                    .clk(clk),
                    .log_m(log_m),
                    .i(i),
                    .read_address(even_read_address),
                    .upper_write_enable(core_write_enable[k][0]),
                    .lower_write_enable(core_write_enable[k][1]),
                    .mode(mode),
                    .upper_write_address(core_address_input[0]),
                    .upper_data_input(core_data_input[k][0]),
                    .lower_write_address(core_address_input[1]),
                    .lower_data_input(core_data_input[k][1]),
                    .r1(router_in[k][0]),
                    .r2(router_in[k][1]),
                    .r3(router_in[k][2]),
                    .r4(router_in[k][3])
                );
            end else begin
                ntt_core #(.MOD_INDEX(MOD_INDEX), .CORE_INDEX(k), .LOG_CORE_COUNT(LOG_CORE_COUNT)) core (
                    .clk(clk),
                    .log_m(log_m),
                    .i(i),
                    .read_address(odd_read_address),
                    .upper_write_enable(core_write_enable[k][0]),
                    .lower_write_enable(core_write_enable[k][1]),
                    .mode(mode),
                    .upper_write_address(core_address_input[0]),
                    .upper_data_input(core_data_input[k][0]),
                    .lower_write_address(core_address_input[1]),
                    .lower_data_input(core_data_input[k][1]),
                    .r1(router_in[k][0]),
                    .r2(router_in[k][1]),
                    .r3(router_in[k][2]),
                    .r4(router_in[k][3])
                );
            end
        end
    endgenerate

    router #(.LOG_CORE_COUNT(LOG_CORE_COUNT)) router (
        .clk(clk),
        .log_m(log_m_pipe[PIPE_STAGES - 3]),
        .log_t(log_t_pipe[PIPE_STAGES - 3]),
        .address_0(address_pipe[0][PIPE_STAGES - 3]),
        .address_1(address_pipe[1][PIPE_STAGES - 3]),
        .in(router_in),
        .loop(router_loop),
        .address_loop(router_address_loop),
        .out(out),
        .address_out(address_out)
    );
    
endmodule