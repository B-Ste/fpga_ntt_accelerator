`timescale 1ns / 1ps

module ntt_core_tb();

    reg clk = 0;
    reg [3:0]log_m;
    reg [9:0]i;
    reg [8:0]upper_read_adress;
    reg [8:0]lower_read_adress;
    reg write_enable;
    reg [1:0]mode;
    reg [8:0]upper_write_adress;
    reg [59:0]upper_data_input;
    reg [8:0]lower_write_adress;
    reg [59:0]lower_data_input;
    wire [29:0]r1, r2, r3 ,r4;

    ntt_core #(.MOD_INDEX(0), .CORE_INDEX(0), .LOG_CORE_COUNT(5)) dut (
        .clk(clk),
        .log_m(log_m),
        .i(i),
        .upper_read_address(upper_read_adress),
        .lower_read_address(lower_read_adress),
        .write_enable(write_enable),
        .mode(mode),
        .upper_write_address(upper_write_adress),
        .upper_data_input(upper_data_input),
        .lower_write_address(lower_write_adress),
        .lower_data_input(lower_data_input),
        .r1(r1),
        .r2(r2),
        .r3(r3),
        .r4(r4));
        
    always #50 clk = ~clk;
        
    initial begin
        upper_read_adress <= 0;
        lower_read_adress <= 0;
        log_m <= 1;
        i <= 0;
        mode <= 0;
        #100;
        i <= 1;
        #100;
        i <= 0;
        log_m <= 2;
        #100;
        log_m <= 3;
        #100;
        mode <= 1;
        #100;
        i <= 1;
        #100;
        i <= 2;
        #100;
        mode <= 3;
        upper_read_adress <= 0;
        lower_read_adress <= 0;
        #100;
        lower_read_adress <= 1;
        upper_read_adress <= 1;
        #100;
        lower_read_adress <= 2;
        upper_read_adress <= 2;
        #100;
        log_m <= 1;
        mode <= 0;
        i <= 0;
        upper_read_adress <= 0;
        lower_read_adress <= 0;
        write_enable <= 1;
        upper_write_adress <= 0;
        upper_data_input <= {30'd0, 30'd100};
        lower_write_adress <= 0;
        lower_data_input <= {30'd0, 30'd10};
        #100;
        upper_write_adress <= 1;
        upper_data_input <= {30'd1, 30'd100};
        lower_write_adress <= 1;
        lower_data_input <= {30'd1, 30'd10};
        #100;
        upper_write_adress <= 2;
        upper_data_input <= {30'd54321, 30'd1};
        lower_write_adress <= 2;
        lower_data_input <= {30'd12345, 30'd10};
        lower_read_adress <= 1;
        upper_read_adress <= 1;
        #100;
        upper_write_adress <= 3;
        upper_data_input <= {30'd72365, 30'd100};
        lower_write_adress <= 3;
        lower_data_input <= {30'd2, 30'd10};
        lower_read_adress <= 2;
        upper_read_adress <= 2;
        #100;
        write_enable <= 0;
        lower_read_adress <= 3;
        upper_read_adress <= 3;
        #100;
        lower_read_adress <= 0;
        upper_read_adress <= 0;
        #100;
        lower_read_adress <= 1;
        upper_read_adress <= 1;
        #100;
        lower_read_adress <= 2;
        upper_read_adress <= 2;
        #100;
        lower_read_adress <= 3;
        upper_read_adress <= 3;
        log_m <= 2;
        #100;
        lower_read_adress <= 0;
        upper_read_adress <= 0;
        #100;
        lower_read_adress <= 1;
        upper_read_adress <= 1;
        #100;
        lower_read_adress <= 2;
        upper_read_adress <= 2;
        #100;
        lower_read_adress <= 3;
        upper_read_adress <= 3;
    end

endmodule