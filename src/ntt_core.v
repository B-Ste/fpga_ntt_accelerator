module ntt_core (
    input clk,
    input [3:0]log_m,
    input [9:0]i,
    input [8:0]read_adress,
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

    parameter mod_index = 0;
    parameter core_index = 0;
    parameter log_core_count = 5;

    reg [11:0] upper_twiddle_index, lower_twiddle_index;
    wire [29:0] upper_twiddle, lower_twiddle;

    generate
        if (core_index % 2 == 0) begin
            always @(posedge clk) begin
                if (mode == 2'd0) begin
                    upper_twiddle_index <= (1 << log_m) + (core_index << log_m) >> log_core_count;
                    lower_twiddle_index <= (1 << log_m) + (core_index << log_m) >> log_core_count;
                end else if (mode == 2'd1) begin
                    upper_twiddle_index <= (1 << log_m) + (core_index << log_m) >> log_core_count + (i << 1);
                    lower_twiddle_index <= (1 << log_m) + (core_index << log_m) >> log_core_count + (i << 1);
                end else begin
                    upper_twiddle_index <= (1 << log_m) + (core_index << log_m) >> log_core_count + (read_adress << 2);
                    lower_twiddle_index <= (1 << log_m) + (core_index << log_m) >> log_core_count + (read_adress << 2) + 1;
                end
            end
        end else begin
            always @(posedge clk) begin
                if (mode == 2'd0) begin
                    upper_twiddle_index <= (1 << log_m) + (core_index << log_m) >> log_core_count;
                    lower_twiddle_index <= (1 << log_m) + (core_index << log_m) >> log_core_count;
                end else if (mode == 2'd1) begin
                    upper_twiddle_index <= (1 << log_m) + ((core_index - 1) << log_m) >> log_core_count + (i << 1);
                    lower_twiddle_index <= (1 << log_m) + ((core_index - 1) << log_m) >> log_core_count + (i << 1);
                end else begin
                    upper_twiddle_index <= (1 << log_m) + ((core_index - 1) << log_m) >> log_core_count + (read_adress << 2) + 2;
                    lower_twiddle_index <= (1 << log_m) + ((core_index - 1) << log_m) >> log_core_count + (read_adress << 2) + 3;
                end    
            end
        end
    endgenerate

    generate
        if (mod_index == 4'd0) begin
            twiddle_table_q0 twiddle_rom_0 (
                .a(upper_twiddle_index),        // input wire [11 : 0] a
                .spo(upper_twiddle)             // output wire [29 : 0] spo
            );
            twiddle_table_q0 twiddle_rom_1 (
                .a(lower_twiddle_index),        // input wire [11 : 0] a
                .spo(lower_twiddle)             // output wire [29 : 0] spo
            );
        end else if (mod_index == 4'd1) begin
            twiddle_table_q1 twiddle_rom_0 (
                .a(upper_twiddle_index),        // input wire [11 : 0] a
                .spo(upper_twiddle)             // output wire [29 : 0] spo
            );
            twiddle_table_q1 twiddle_rom_1 (
                .a(lower_twiddle_index),        // input wire [11 : 0] a
                .spo(lower_twiddle)             // output wire [29 : 0] spo
            );
        end else if (mod_index == 4'd2) begin
            twiddle_table_q2 twiddle_rom_0 (
                .a(upper_twiddle_index),        // input wire [11 : 0] a
                .spo(upper_twiddle)             // output wire [29 : 0] spo
            );
            twiddle_table_q2 twiddle_rom_1 (
                .a(lower_twiddle_index),        // input wire [11 : 0] a
                .spo(lower_twiddle)             // output wire [29 : 0] spo
            );
        end else if (mod_index == 4'd3) begin
            twiddle_table_q3 twiddle_rom_0 (
                .a(upper_twiddle_index),        // input wire [11 : 0] a
                .spo(upper_twiddle)             // output wire [29 : 0] spo
            );
            twiddle_table_q3 twiddle_rom_1 (
                .a(lower_twiddle_index),        // input wire [11 : 0] a
                .spo(lower_twiddle)             // output wire [29 : 0] spo
            );
        end else if (mod_index == 4'd4) begin
            twiddle_table_q4 twiddle_rom_0 (
                .a(upper_twiddle_index),        // input wire [11 : 0] a
                .spo(upper_twiddle)             // output wire [29 : 0] spo
            );
            twiddle_table_q4 twiddle_rom_1 (
                .a(lower_twiddle_index),        // input wire [11 : 0] a
                .spo(lower_twiddle)             // output wire [29 : 0] spo
            );
        end else if (mod_index == 4'd5) begin
            twiddle_table_q5 twiddle_rom_0 (
                .a(upper_twiddle_index),        // input wire [11 : 0] a
                .spo(upper_twiddle)             // output wire [29 : 0] spo
            );
            twiddle_table_q5 twiddle_rom_1 (
                .a(lower_twiddle_index),        // input wire [11 : 0] a
                .spo(lower_twiddle)             // output wire [29 : 0] spo
            );
        end else if (mod_index == 4'd6) begin
            twiddle_table_q6 twiddle_rom_0 (
                .a(upper_twiddle_index),        // input wire [11 : 0] a
                .spo(upper_twiddle)             // output wire [29 : 0] spo
            );
            twiddle_table_q6 twiddle_rom_1 (
                .a(lower_twiddle_index),        // input wire [11 : 0] a
                .spo(lower_twiddle)             // output wire [29 : 0] spo
            );
        end else if (mod_index == 4'd7) begin
            twiddle_table_q7 twiddle_rom_0 (
                .a(upper_twiddle_index),        // input wire [11 : 0] a
                .spo(upper_twiddle)             // output wire [29 : 0] spo
            );
            twiddle_table_q7 twiddle_rom_1 (
                .a(lower_twiddle_index),        // input wire [11 : 0] a
                .spo(lower_twiddle)             // output wire [29 : 0] spo
            );
        end else if (mod_index == 4'd8) begin
            twiddle_table_q8 twiddle_rom_0 (
                .a(upper_twiddle_index),        // input wire [11 : 0] a
                .spo(upper_twiddle)             // output wire [29 : 0] spo
            );
            twiddle_table_q8 twiddle_rom_1 (
                .a(lower_twiddle_index),        // input wire [11 : 0] a
                .spo(lower_twiddle)             // output wire [29 : 0] spo
            );
        end else if (mod_index == 4'd9) begin
            twiddle_table_q9 twiddle_rom_0 (
                .a(upper_twiddle_index),        // input wire [11 : 0] a
                .spo(upper_twiddle)             // output wire [29 : 0] spo
            );
            twiddle_table_q9 twiddle_rom_1 (
                .a(lower_twiddle_index),        // input wire [11 : 0] a
                .spo(lower_twiddle)             // output wire [29 : 0] spo
            );
        end else if (mod_index == 4'd10) begin
            twiddle_table_q10 twiddle_rom_0 (
                .a(upper_twiddle_index),        // input wire [11 : 0] a
                .spo(upper_twiddle)             // output wire [29 : 0] spo
            );
            twiddle_table_q10 twiddle_rom_1 (
                .a(lower_twiddle_index),        // input wire [11 : 0] a
                .spo(lower_twiddle)             // output wire [29 : 0] spo
            );
        end else if (mod_index == 4'd11) begin
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
        .addrb(read_adress),            // input wire [8 : 0] addrb
        .doutb(upper_bram_output)       // output wire [59 : 0] doutb
    );

    ntt_core_bram lower_bram (
        .clka(clk),                     // input wire clka
        .wea(write_enable),             // input wire [0 : 0] wea
        .addra(lower_write_address),    // input wire [8 : 0] addra
        .dina(lower_data_input),        // input wire [59 : 0] dina
        .clkb(clk),                     // input wire clkb
        .addrb(read_adress),            // input wire [8 : 0] addrb
        .doutb(lower_bram_output)       // output wire [59 : 0] doutb
    );

    ct_butterfly upper_butterfly(
        .clk(clk),
        .a(upper_bram_output[29:0]),
        .b(upper_bram_output[59:30]),
        .w(upper_twiddle),
        .A(r1),
        .B(r2)
    );

    ct_butterfly lower_butterfly(
        .clk(clk),
        .a(lower_bram_output[29:0]),
        .b(lower_bram_output[59:30]),
        .w(lower_twiddle),
        .A(r3),
        .B(r4)
    );
    
endmodule