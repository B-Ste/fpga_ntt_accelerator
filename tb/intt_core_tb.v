`timescale 1ns/1ps

module intt_core_tb ();

    reg clk = 0;
    reg [3:0]log_m;
    reg [9:0]upper_i, lower_i;
    reg [8:0]upper_read_address;
    reg [8:0]lower_read_address;
    reg write_enable;
    reg write_select;
    reg read_select;
    reg input_select;
    reg [1:0]mode;
    reg [8:0]upper_write_address;
    reg [59:0]upper_data_input;
    reg [59:0]upper_direct_input;
    reg [8:0]lower_write_address;
    reg [59:0]lower_data_input;
    reg [59:0]lower_direct_input;
    wire [29:0]r1;
    wire [29:0]r2;
    wire [29:0]r3;
    wire [29:0]r4;

    intt_core #(.MOD_INDEX(0), .CORE_INDEX(1), .LOG_CORE_COUNT(4)) dut (
        .clk(clk),
        .log_m(log_m),
        .upper_i(upper_i),
        .lower_i(lower_i),
        .upper_read_address(upper_read_address),
        .lower_read_address(lower_read_address),
        .write_enable(write_enable),
        .write_select(write_select),
        .read_select(read_select),
        .input_select(input_select),
        .mode(mode),
        .upper_write_address(upper_write_address),
        .upper_data_input(upper_data_input),
        .upper_direct_input(upper_direct_input),
        .lower_write_address(lower_write_address),
        .lower_data_input(lower_data_input),
        .lower_direct_input(lower_direct_input),
        .r1(r1),
        .r2(r2),
        .r3(r3),
        .r4(r4));

    always #50 clk = ~clk;
    
    initial begin
        log_m <= 12;
        upper_i <= 0;
        lower_i <= 0;
        mode <= 0;
        upper_read_address <= 0;
        lower_read_address <= 0;
        write_enable <= 0;
        write_select <= 1;
        read_select <= 0;
        input_select <= 0;
        upper_write_address <= 0;
        upper_data_input <= 0;
        lower_write_address <= 0;
        lower_data_input <= 0;
        #100;
        upper_i <= 1;
        lower_i <= 0;
        #100;
        upper_i <= 0;
        lower_i <= 1;
        upper_read_address <= 1;
        #100;
        upper_read_address <= 2;
        lower_read_address <= 1;
        #100;
        lower_read_address <= 2;
        #100;
        mode <= 1;
        lower_i <= 0;
        log_m <= 11;
        #100;
        upper_read_address <= 0;
        lower_read_address <= 0;
        #100;
        upper_i <= 1;
        lower_i <= 0;
        #100;
        upper_i <= 1;
        lower_i <= 2;
        #100;
        upper_i <= 0;
        lower_i <= 0;
        log_m <= 10;
        #100;
        mode <= 2;
        log_m <= 5;
        #100;
        upper_i <= 1;
        lower_i <= 1;
        #100;
        upper_read_address <= 1;
        lower_read_address <= 2;
        #100;
        log_m <= 4;
        #100;
        log_m <= 12;
        upper_i <= 0;
        lower_i <= 0;
        mode <= 0;
        upper_read_address <= 0;
        lower_read_address <= 0;
        write_enable <= 1;
        write_select <= 1;
        read_select <= 0;
        upper_write_address <= 0;
        upper_data_input <= 100;
        lower_write_address <= 0;
        lower_data_input <= 10;
        #100;
        upper_write_address <= 1;
        upper_data_input <= 110;
        lower_write_address <= 1;
        lower_data_input <= 11;
        #100;
        upper_write_address <= 2;
        upper_data_input <= 120;
        lower_write_address <= 2;
        lower_data_input <= 12;
        #100;
        read_select <= 1;
        upper_write_address <= 3;
        upper_data_input <= 130;
        lower_write_address <= 3;
        lower_data_input <= 13;
        #100;
        write_select <= 0;
        upper_read_address <= 1;
        lower_read_address <= 1;
        upper_write_address <= 0;
        upper_data_input <= {30'd123, 30'd456};
        lower_write_address <= 0;
        lower_data_input <= {30'd897, 30'd698};
        #100;
        upper_read_address <= 2;
        lower_read_address <= 3;
        #200;
        read_select <= 0;
        upper_read_address <= 0;
        lower_read_address <= 0;
        #100;
        input_select <= 1;
        upper_direct_input <= 500;
        lower_direct_input <= 50;
        #100;
        upper_direct_input <= 600;
        lower_direct_input <= 60;
        #100;
        input_select <= 0;
    end

endmodule