module ntt_core (
    input clk,
    input [3:0]log_m,
    input [9:0]i,
    input [8:0]upper_read_address,
    input [8:0]lower_read_address,
    input write_enable,
    input [1:0]mode,
    input [8:0]upper_write_address,
    input [59:0]upper_data_input,
    input [8:0]lower_write_address,
    input [59:0]lower_data_input,
    output [29:0]r1,
    output [29:0]r2,
    output [29:0]r3,
    output [29:0]r4);

    parameter MOD_INDEX = 0;
    parameter CORE_INDEX = 11'd0;
    parameter LOG_CORE_COUNT = 5;

    wire [11:0] upper_twiddle_index, lower_twiddle_index;
    wire [29:0] upper_twiddle, lower_twiddle;

    generate
        if (CORE_INDEX % 2 == 0) begin
            assign upper_twiddle_index = (mode == 2'd0) ? (12'd1 << log_m) + ((CORE_INDEX << log_m) >> LOG_CORE_COUNT) :
                                         (mode == 2'd1) ? (12'd1 << log_m) + ((CORE_INDEX << log_m) >> LOG_CORE_COUNT) + (i << 1) : 
                                         (12'd1 << log_m) + ((CORE_INDEX << log_m) >> LOG_CORE_COUNT) + (upper_read_address << 2);
            assign lower_twiddle_index = (mode == 2'd0) ? (12'd1 << log_m) + ((CORE_INDEX << log_m) >> LOG_CORE_COUNT) :
                                         (mode == 2'd1) ? (12'd1 << log_m) + ((CORE_INDEX << log_m) >> LOG_CORE_COUNT) + (i << 1) : 
                                         (12'd1 << log_m) + ((CORE_INDEX << log_m) >> LOG_CORE_COUNT) + (lower_read_address << 2) + 1;
        end else begin
            assign upper_twiddle_index = (mode == 2'd0) ? (12'd1 << log_m) + ((CORE_INDEX << log_m) >> LOG_CORE_COUNT) :
                                         (mode == 2'd1) ? (12'd1 << log_m) + ((CORE_INDEX << log_m) >> LOG_CORE_COUNT) + (i << 1) : 
                                         (12'd1 << log_m) + ((CORE_INDEX << log_m) >> LOG_CORE_COUNT) + (upper_read_address << 2) + 2;
            assign lower_twiddle_index = (mode == 2'd0) ? (12'd1 << log_m) + ((CORE_INDEX << log_m) >> LOG_CORE_COUNT) :
                                         (mode == 2'd1) ? (12'd1 << log_m) + ((CORE_INDEX << log_m) >> LOG_CORE_COUNT) + (i << 1) : 
                                         (12'd1 << log_m) + ((CORE_INDEX << log_m) >> LOG_CORE_COUNT) + (lower_read_address << 2) + 3;
        end
    endgenerate

    generate
        if (MOD_INDEX == 4'd0) begin
            twiddle_table_q0 twiddle_rom_0 (
                .a(upper_twiddle_index),        // input wire [11 : 0] a
                .spo(upper_twiddle)             // output wire [29 : 0] spo
            );
            twiddle_table_q0 twiddle_rom_1 (
                .a(lower_twiddle_index),        // input wire [11 : 0] a
                .spo(lower_twiddle)             // output wire [29 : 0] spo
            );
        end else if (MOD_INDEX == 4'd1) begin
            twiddle_table_q1 twiddle_rom_0 (
                .a(upper_twiddle_index),        // input wire [11 : 0] a
                .spo(upper_twiddle)             // output wire [29 : 0] spo
            );
            twiddle_table_q1 twiddle_rom_1 (
                .a(lower_twiddle_index),        // input wire [11 : 0] a
                .spo(lower_twiddle)             // output wire [29 : 0] spo
            );
        end else if (MOD_INDEX == 4'd2) begin
            twiddle_table_q2 twiddle_rom_0 (
                .a(upper_twiddle_index),        // input wire [11 : 0] a
                .spo(upper_twiddle)             // output wire [29 : 0] spo
            );
            twiddle_table_q2 twiddle_rom_1 (
                .a(lower_twiddle_index),        // input wire [11 : 0] a
                .spo(lower_twiddle)             // output wire [29 : 0] spo
            );
        end else if (MOD_INDEX == 4'd3) begin
            twiddle_table_q3 twiddle_rom_0 (
                .a(upper_twiddle_index),        // input wire [11 : 0] a
                .spo(upper_twiddle)             // output wire [29 : 0] spo
            );
            twiddle_table_q3 twiddle_rom_1 (
                .a(lower_twiddle_index),        // input wire [11 : 0] a
                .spo(lower_twiddle)             // output wire [29 : 0] spo
            );
        end else if (MOD_INDEX == 4'd4) begin
            twiddle_table_q4 twiddle_rom_0 (
                .a(upper_twiddle_index),        // input wire [11 : 0] a
                .spo(upper_twiddle)             // output wire [29 : 0] spo
            );
            twiddle_table_q4 twiddle_rom_1 (
                .a(lower_twiddle_index),        // input wire [11 : 0] a
                .spo(lower_twiddle)             // output wire [29 : 0] spo
            );
        end else if (MOD_INDEX == 4'd5) begin
            twiddle_table_q5 twiddle_rom_0 (
                .a(upper_twiddle_index),        // input wire [11 : 0] a
                .spo(upper_twiddle)             // output wire [29 : 0] spo
            );
            twiddle_table_q5 twiddle_rom_1 (
                .a(lower_twiddle_index),        // input wire [11 : 0] a
                .spo(lower_twiddle)             // output wire [29 : 0] spo
            );
        end else if (MOD_INDEX == 4'd6) begin
            twiddle_table_q6 twiddle_rom_0 (
                .a(upper_twiddle_index),        // input wire [11 : 0] a
                .spo(upper_twiddle)             // output wire [29 : 0] spo
            );
            twiddle_table_q6 twiddle_rom_1 (
                .a(lower_twiddle_index),        // input wire [11 : 0] a
                .spo(lower_twiddle)             // output wire [29 : 0] spo
            );
        end else if (MOD_INDEX == 4'd7) begin
            twiddle_table_q7 twiddle_rom_0 (
                .a(upper_twiddle_index),        // input wire [11 : 0] a
                .spo(upper_twiddle)             // output wire [29 : 0] spo
            );
            twiddle_table_q7 twiddle_rom_1 (
                .a(lower_twiddle_index),        // input wire [11 : 0] a
                .spo(lower_twiddle)             // output wire [29 : 0] spo
            );
        end else if (MOD_INDEX == 4'd8) begin
            twiddle_table_q8 twiddle_rom_0 (
                .a(upper_twiddle_index),        // input wire [11 : 0] a
                .spo(upper_twiddle)             // output wire [29 : 0] spo
            );
            twiddle_table_q8 twiddle_rom_1 (
                .a(lower_twiddle_index),        // input wire [11 : 0] a
                .spo(lower_twiddle)             // output wire [29 : 0] spo
            );
        end else if (MOD_INDEX == 4'd9) begin
            twiddle_table_q9 twiddle_rom_0 (
                .a(upper_twiddle_index),        // input wire [11 : 0] a
                .spo(upper_twiddle)             // output wire [29 : 0] spo
            );
            twiddle_table_q9 twiddle_rom_1 (
                .a(lower_twiddle_index),        // input wire [11 : 0] a
                .spo(lower_twiddle)             // output wire [29 : 0] spo
            );
        end else if (MOD_INDEX == 4'd10) begin
            twiddle_table_q10 twiddle_rom_0 (
                .a(upper_twiddle_index),        // input wire [11 : 0] a
                .spo(upper_twiddle)             // output wire [29 : 0] spo
            );
            twiddle_table_q10 twiddle_rom_1 (
                .a(lower_twiddle_index),        // input wire [11 : 0] a
                .spo(lower_twiddle)             // output wire [29 : 0] spo
            );
        end else if (MOD_INDEX == 4'd11) begin
            twiddle_table_q11 twiddle_rom_0 (
                .a(upper_twiddle_index),        // input wire [11 : 0] a
                .spo(upper_twiddle)             // output wire [29 : 0] spo
            );
            twiddle_table_q11 twiddle_rom_1 (
                .a(lower_twiddle_index),        // input wire [11 : 0] a
                .spo(lower_twiddle)             // output wire [29 : 0] spo
            );
        end else begin
            twiddle_table_q12 twiddle_rom_0 (
                .a(upper_twiddle_index),        // input wire [11 : 0] a
                .spo(upper_twiddle)             // output wire [29 : 0] spo
            );
            twiddle_table_q12 twiddle_rom_1 (
                .a(lower_twiddle_index),        // input wire [11 : 0] a
                .spo(lower_twiddle)             // output wire [29 : 0] spo
            );
        end
    endgenerate

    wire [59:0]upper_bram_output, lower_bram_output;

    ntt_core_bram upper_bram (
        .clka(clk),                     // input wire clka
        .wea(write_enable),             // input wire [0 : 0] wea
        .addra(upper_write_address),    // input wire [8 : 0] addra
        .dina(upper_data_input),        // input wire [59 : 0] dina
        .clkb(clk),                     // input wire clkb
        .addrb(upper_read_address),     // input wire [8 : 0] addrb
        .doutb(upper_bram_output)       // output wire [59 : 0] doutb
    );

    ntt_core_bram lower_bram (
        .clka(clk),                     // input wire clka
        .wea(write_enable),             // input wire [0 : 0] wea
        .addra(lower_write_address),    // input wire [8 : 0] addra
        .dina(lower_data_input),        // input wire [59 : 0] dina
        .clkb(clk),                     // input wire clkb
        .addrb(lower_read_address),     // input wire [8 : 0] addrb
        .doutb(lower_bram_output)       // output wire [59 : 0] doutb
    );

    ct_butterfly #MOD_INDEX upper_butterfly(
        .clk(clk),
        .a(upper_bram_output[29:0]),
        .b(upper_bram_output[59:30]),
        .w(upper_twiddle),
        .A(r1),
        .B(r2)
    );

    ct_butterfly #MOD_INDEX lower_butterfly(
        .clk(clk),
        .a(lower_bram_output[29:0]),
        .b(lower_bram_output[59:30]),
        .w(lower_twiddle),
        .A(r3),
        .B(r4)
    );
    
endmodule