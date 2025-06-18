module ntt_processor #(
    parameter MOD_INDEX = 0,
    parameter LOG_CORE_COUNT = 5) (
        input clk,
        input write_enable,
        input [10:0]address_in,
        input [59:0]data_in,
        output [59:0]out[(1 << LOG_CORE_COUNT) - 1:0][1:0],
        output [8:0]address_out[(1 << LOG_CORE_COUNT) - 1:0]
    );

    reg core_write_enable[(1 << LOG_CORE_COUNT) - 1:0][1:0];
    reg [1:0]mode;
    reg [3:0]log_m;
    reg [3:0]log_t;
    reg [9:0]i;
    reg [8:0]upper_read_address;
    reg [8:0]lower_read_address; 
    reg [8:0]upper_write_address; 
    reg [8:0]lower_write_address;
    wire [29:0]router_in[(1 << LOG_CORE_COUNT) - 1:0][3:0];
    wire [59:0]core_data_input[(1 << LOG_CORE_COUNT) - 1:0][1:0];
    wire [59:0]router_loop[(1 << LOG_CORE_COUNT) - 1:0][1:0];
    wire [8:0]core_address_input[(1 << LOG_CORE_COUNT) - 1:0][1:0];
    wire [8:0]router_address_loop[(1 << LOG_CORE_COUNT) - 1:0][1:0];

    // Muxes to switch between processor input and router input
    integer i;
    for (int i = 0; i < (1 << LOG_CORE_COUNT); i = i + 1) begin
        assign core_data_input[i][0] = write_enable ? data_in : router_loop[i][0];
        assign core_data_input[i][1] = write_enable ? data_in : router_loop[i][1];
        assign core_address_input[i][0] = write_enable ? 
            {{(LOG_CORE_COUNT - 1) {1'd0}}, address_in[(9 - LOG_CORE_COUNT):0]} : router_address_loop[i][0];
        assign core_address_input[i][1] = write_enable ? 
            {{(LOG_CORE_COUNT - 1) {1'd0}}, address_in[(9 - LOG_CORE_COUNT):0]} : router_address_loop[i][1];
    end

    localparam PIPE_STAGES = 10;
    reg [3:0] pipe_threshold;
    wire [9:0] i_threshold = (log_m - LOG_CORE_COUNT >= 0) ? (1 << (log_m - LOG_CORE_COUNT)) : 0;
    always @(posedge clk ) begin
        if (write_enable) begin
            mode <= 0;
            log_m <= 0;
            log_t <= 10;
            i <= 0;
            upper_read_address <= 0;
            lower_read_address <= 0;
            upper_write_address <= 0;
            upper_write_address <= 0;
            pipe_threshold = 0;
            // Only enable writing on the targeted processor
            for (i = 0; i < (1 << LOG_CORE_COUNT); i = i + 1) begin
                if (i == address_in[9:(9 - LOG_CORE_COUNT + 1)]) begin
                    if (address_in[10] == 0) begin
                        core_write_enable[i][0] <= 1;
                        core_write_enable[i][1] <= 0;
                    end else begin
                        core_write_enable[i][0] <= 0;
                        core_write_enable[i][1] <= 1;
                    end
                end else begin
                    core_write_enable[i][0] <= 0;
                    core_write_enable[i][1] <= 0;
                end
            end
        end else begin

            // enable writing back to memory only when the first new coefficients are through the pipeline.
            pipe_threshold <= pipe_threshold + 1;
            if (pipe_threshold == PIPE_STAGES) begin
                for (i = 0; i < (1 << LOG_CORE_COUNT); i = i + 1) begin
                    core_write_enable[i][0] <= 1;
                    core_write_enable[i][1] <= 1;
                end 
            end

        end
    end

    genvar k;
    generate
        for (k = 0; k < (6'd1 << LOG_CORE_COUNT); k = k + 1) begin
            ntt_core #(.MOD_INDEX(MOD_INDEX), .CORE_INDEX(k), .LOG_CORE_COUNT(LOG_CORE_COUNT)) core (
                .clk(clk),
                .log_m(log_m),
                .i(i),
                .upper_read_address(upper_read_address),
                .lower_read_address(lower_read_address),
                .upper_write_enable(core_write_enable[i][0]),
                .lower_write_enable(core_write_enable[i][1]),
                .mode(mode),
                .upper_write_address(core_address_input[k][0]),
                .upper_data_input(core_data_input[k][0]),
                .lower_write_address(core_address_input[k][1]),
                .lower_data_input(core_data_input[k][1]),
                .r1(router_in[k][0]),
                .r2(router_in[k][1]),
                .r3(router_in[k][2]),
                .r4(router_in[k][3])
            );
        end
    endgenerate

    router #(.LOG_CORE_COUNT(LOG_CORE_COUNT)) router (
        .clk(clk),
        .log_m(log_m),
        .log_t(log_t),
        .address_0(upper_read_address),
        .address_1(lower_read_address),
        .in(router_in),
        .loop(router_loop),
        .address_loop(router_address_loop),
        .out(out),
        .address_out(address_out)
    );
    
endmodule