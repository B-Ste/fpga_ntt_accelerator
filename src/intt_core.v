module intt_core #(
    parameter MOD_INDEX = 0,
    parameter CORE_INDEX = 0,
    parameter LOG_CORE_COUNT = 4) (
        input clk,
        input [3:0]log_m,
        input [9:0]i,
        input [8:0]upper_read_address,
        input [8:0]lower_read_address,
        input upper_write_enable,
        input lower_write_enable,
        input write_select,
        input read_select,
        input [1:0]mode,
        input [8:0]upper_write_address,
        input [59:0]upper_data_input,
        input [8:0]lower_write_address,
        input [59:0]lower_data_input,
        output [29:0]r1,
        output [29:0]r2,
        output [29:0]r3,
        output [29:0]r4);

    wire [11:0] upper_twiddle_index, lower_twiddle_index;
    wire [29:0] upper_twiddle, lower_twiddle;
    reg [29:0] upper_twiddle_reg;
    reg [29:0] lower_twiddle_reg;

    generate
        if (CORE_INDEX % 2 == 0) begin
            assign upper_twiddle_index = (mode == 0) ? (1 << (log_m - 1)) + ((CORE_INDEX << log_m) >> (LOG_CORE_COUNT + 1)) + (upper_read_address << 2) : 
                                         (mode == 1) ? (1 << (log_m - 1)) + ((CORE_INDEX << log_m) >> (LOG_CORE_COUNT + 1)) + (i << 1) : 
                                         (1 << (log_m - 1)) + ((CORE_INDEX << log_m) >> (LOG_CORE_COUNT + 1));
            assign lower_twiddle_index = (mode == 0) ? (1 << (log_m - 1)) + ((CORE_INDEX << log_m) >> (LOG_CORE_COUNT + 1)) + (lower_read_address << 2) + 1 :
                                         (mode == 1) ? (1 << (log_m - 1)) + ((CORE_INDEX << log_m) >> (LOG_CORE_COUNT + 1)) + (i << 1) : 
                                         (1 << (log_m - 1)) + ((CORE_INDEX << log_m) >> (LOG_CORE_COUNT + 1));
        end else begin
            assign upper_twiddle_index = (mode == 0) ? (1 << (log_m - 1)) + (((CORE_INDEX - 1) << log_m) >> (LOG_CORE_COUNT + 1)) + (upper_read_address << 2) + 2: 
                                         (mode == 1) ? (1 << (log_m - 1)) + (((CORE_INDEX - 1) << log_m) >> (LOG_CORE_COUNT + 1)) + (i << 1) + 1 : 
                                         (1 << (log_m - 1)) + ((CORE_INDEX << log_m) >> (LOG_CORE_COUNT + 1));
            assign lower_twiddle_index = (mode == 0) ? (1 << (log_m - 1)) + (((CORE_INDEX - 1) << log_m) >> (LOG_CORE_COUNT + 1)) + (lower_read_address << 2) + 3 :
                                         (mode == 1) ? (1 << (log_m - 1)) + (((CORE_INDEX - 1) << log_m) >> (LOG_CORE_COUNT + 1)) + (i << 1) + 1 : 
                                         (1 << (log_m - 1)) + ((CORE_INDEX << log_m) >> (LOG_CORE_COUNT + 1));
        end
    endgenerate

    always @(posedge clk) begin
        upper_twiddle_reg <= upper_twiddle;
        lower_twiddle_reg <= lower_twiddle;
    end

    generate
        if (MOD_INDEX == 4'd0) begin
            inv_twiddle_table_0 twiddle_rom_0 (
                .a(upper_twiddle_index),        // input wire [11 : 0] a
                .spo(upper_twiddle)             // output wire [29 : 0] spo
            );
            inv_twiddle_table_0 twiddle_rom_1 (
                .a(lower_twiddle_index),        // input wire [11 : 0] a
                .spo(lower_twiddle)             // output wire [29 : 0] spo
            );
        end else if (MOD_INDEX == 4'd1) begin
            inv_twiddle_table_1 twiddle_rom_0 (
                .a(upper_twiddle_index),        // input wire [11 : 0] a
                .spo(upper_twiddle)             // output wire [29 : 0] spo
            );
            inv_twiddle_table_1 twiddle_rom_1 (
                .a(lower_twiddle_index),        // input wire [11 : 0] a
                .spo(lower_twiddle)             // output wire [29 : 0] spo
            );
        end else if (MOD_INDEX == 4'd2) begin
            inv_twiddle_table_2 twiddle_rom_0 (
                .a(upper_twiddle_index),        // input wire [11 : 0] a
                .spo(upper_twiddle)             // output wire [29 : 0] spo
            );
            inv_twiddle_table_2 twiddle_rom_1 (
                .a(lower_twiddle_index),        // input wire [11 : 0] a
                .spo(lower_twiddle)             // output wire [29 : 0] spo
            );
        end else if (MOD_INDEX == 4'd3) begin
            inv_twiddle_table_3 twiddle_rom_0 (
                .a(upper_twiddle_index),        // input wire [11 : 0] a
                .spo(upper_twiddle)             // output wire [29 : 0] spo
            );
            inv_twiddle_table_3 twiddle_rom_1 (
                .a(lower_twiddle_index),        // input wire [11 : 0] a
                .spo(lower_twiddle)             // output wire [29 : 0] spo
            );
        end else if (MOD_INDEX == 4'd4) begin
            inv_twiddle_table_4 twiddle_rom_0 (
                .a(upper_twiddle_index),        // input wire [11 : 0] a
                .spo(upper_twiddle)             // output wire [29 : 0] spo
            );
            inv_twiddle_table_4 twiddle_rom_1 (
                .a(lower_twiddle_index),        // input wire [11 : 0] a
                .spo(lower_twiddle)             // output wire [29 : 0] spo
            );
        end else if (MOD_INDEX == 4'd5) begin
            inv_twiddle_table_5 twiddle_rom_0 (
                .a(upper_twiddle_index),        // input wire [11 : 0] a
                .spo(upper_twiddle)             // output wire [29 : 0] spo
            );
            inv_twiddle_table_5 twiddle_rom_1 (
                .a(lower_twiddle_index),        // input wire [11 : 0] a
                .spo(lower_twiddle)             // output wire [29 : 0] spo
            );
        end else if (MOD_INDEX == 4'd6) begin
            inv_twiddle_table_6 twiddle_rom_0 (
                .a(upper_twiddle_index),        // input wire [11 : 0] a
                .spo(upper_twiddle)             // output wire [29 : 0] spo
            );
            inv_twiddle_table_6 twiddle_rom_1 (
                .a(lower_twiddle_index),        // input wire [11 : 0] a
                .spo(lower_twiddle)             // output wire [29 : 0] spo
            );
        end else if (MOD_INDEX == 4'd7) begin
            inv_twiddle_table_7 twiddle_rom_0 (
                .a(upper_twiddle_index),        // input wire [11 : 0] a
                .spo(upper_twiddle)             // output wire [29 : 0] spo
            );
            inv_twiddle_table_7 twiddle_rom_1 (
                .a(lower_twiddle_index),        // input wire [11 : 0] a
                .spo(lower_twiddle)             // output wire [29 : 0] spo
            );
        end else if (MOD_INDEX == 4'd8) begin
            inv_twiddle_table_8 twiddle_rom_0 (
                .a(upper_twiddle_index),        // input wire [11 : 0] a
                .spo(upper_twiddle)             // output wire [29 : 0] spo
            );
            inv_twiddle_table_8 twiddle_rom_1 (
                .a(lower_twiddle_index),        // input wire [11 : 0] a
                .spo(lower_twiddle)             // output wire [29 : 0] spo
            );
        end else if (MOD_INDEX == 4'd9) begin
            inv_twiddle_table_9 twiddle_rom_0 (
                .a(upper_twiddle_index),        // input wire [11 : 0] a
                .spo(upper_twiddle)             // output wire [29 : 0] spo
            );
            inv_twiddle_table_9 twiddle_rom_1 (
                .a(lower_twiddle_index),        // input wire [11 : 0] a
                .spo(lower_twiddle)             // output wire [29 : 0] spo
            );
        end else if (MOD_INDEX == 4'd10) begin
            inv_twiddle_table_10 twiddle_rom_0 (
                .a(upper_twiddle_index),        // input wire [11 : 0] a
                .spo(upper_twiddle)             // output wire [29 : 0] spo
            );
            inv_twiddle_table_10 twiddle_rom_1 (
                .a(lower_twiddle_index),        // input wire [11 : 0] a
                .spo(lower_twiddle)             // output wire [29 : 0] spo
            );
        end else if (MOD_INDEX == 4'd11) begin
            inv_twiddle_table_11 twiddle_rom_0 (
                .a(upper_twiddle_index),        // input wire [11 : 0] a
                .spo(upper_twiddle)             // output wire [29 : 0] spo
            );
            inv_twiddle_table_11 twiddle_rom_1 (
                .a(lower_twiddle_index),        // input wire [11 : 0] a
                .spo(lower_twiddle)             // output wire [29 : 0] spo
            );
        end else begin
            inv_twiddle_table_12 twiddle_rom_0 (
                .a(upper_twiddle_index),        // input wire [11 : 0] a
                .spo(upper_twiddle)             // output wire [29 : 0] spo
            );
            inv_twiddle_table_12 twiddle_rom_1 (
                .a(lower_twiddle_index),        // input wire [11 : 0] a
                .spo(lower_twiddle)             // output wire [29 : 0] spo
            );
        end
    endgenerate

    wire [59:0]upper_bram_output, lower_bram_output;

    core_ram #(.LOG_CORE_COUNT(LOG_CORE_COUNT)) upper_ram (
        .clk(clk),
        .write_select(write_select),
        .write_enable(upper_write_enable),
        .read_select(read_select),
        .write_address(upper_write_address),
        .data_in(upper_data_input),
        .read_address(upper_read_address),
        .data_out(upper_bram_output));

    core_ram #(.LOG_CORE_COUNT(LOG_CORE_COUNT)) lower_ram (
        .clk(clk),
        .write_select(write_select),
        .write_enable(lower_write_enable),
        .read_select(read_select),
        .write_address(lower_write_address),
        .data_in(lower_data_input),
        .read_address(lower_read_address),
        .data_out(lower_bram_output));

    gs_butterfly #MOD_INDEX upper_butterfly(
        .clk(clk),
        .A(upper_bram_output[29:0]),
        .B(upper_bram_output[59:30]),
        .w(upper_twiddle_reg),
        .a(r1),
        .b(r2)
    );

    gs_butterfly #MOD_INDEX lower_butterfly(
        .clk(clk),
        .A(lower_bram_output[29:0]),
        .B(lower_bram_output[59:30]),
        .w(lower_twiddle_reg),
        .a(r3),
        .b(r4)
    );

endmodule