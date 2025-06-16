module ntt_processor #(
    parameter MOD_INDEX = 0,
    parameter LOG_CORE_COUNT = 5) (
        input clk,
        output [59:0]out[(1 << LOG_CORE_COUNT) - 1:0][1:0],
        output [8:0]address_out[(1 << LOG_CORE_COUNT) - 1:0]
    );

    reg write_enable = 0;
    reg [1:0]mode = 0;
    reg [3:0]log_m = 1;
    reg [3:0]log_t = 1024;
    reg [9:0]i = 0;
    reg [8:0]upper_read_address = 0;
    reg [8:0]lower_read_address = 0; 
    reg [8:0]write_adress_0 = 0; 
    reg [8:0]write_adress_1 = 0;
    wire [29:0]router_in[(1 << LOG_CORE_COUNT) - 1:0][3:0];
    wire [59:0]router_loop[(1 << LOG_CORE_COUNT) - 1:0][1:0];
    wire [8:0]router_address_loop[(1 << LOG_CORE_COUNT) - 1:0][1:0];

    genvar k;
    generate
        for (k = 0; k < (6'd1 << LOG_CORE_COUNT); k = k + 1) begin
            ntt_core #(.MOD_INDEX(MOD_INDEX), .CORE_INDEX(k), .LOG_CORE_COUNT(LOG_CORE_COUNT)) core (
                .clk(clk),
                .log_m(log_m),
                .i(i),
                .upper_read_address(upper_read_address),
                .lower_read_address(lower_read_address),
                .write_enable(write_enable),
                .mode(mode),
                .upper_write_address(router_address_loop[k][0]),
                .upper_data_input(router_loop[k][0]),
                .lower_write_address(router_address_loop[k][1]),
                .lower_data_input(router_loop[k][1]),
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