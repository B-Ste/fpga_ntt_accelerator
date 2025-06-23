module ntt_core_ram_tb ();

    reg clk = 0;
    reg write_select, read_select;
    reg write_enable;
    reg [4:0]write_address, read_address;
    reg [59:0]data_in; 
    wire [59:0]data_out;

    ntt_core_ram #(.LOG_CORE_COUNT(5)) dut (
        .clk(clk),
        .write_select(write_select),
        .write_enable(write_enable),
        .read_select(read_select),
        .write_address(write_address),
        .data_in(data_in),
        .read_address(read_address),
        .data_out(data_out));

    always #50 clk = ~clk;

    initial begin
        write_select = 0;
        read_select = 1;
        write_enable = 1;
        write_address = 0;
        read_address = 0;
        data_in = 100;
        #100;
        write_address = 1;
        data_in = 110;
        #100;
        write_address = 2;
        data_in = 120;
        #100;
        write_enable = 0;
        write_address = 3;
        data_in = 130;
        #100;
        write_select = 1;
        read_select = 0;
        #100;
        write_enable = 1;
        write_address = 0;
        data_in = 200;
        read_address = 1;
        #100;
        write_address = 2;
        data_in = 210;
        read_address = 2;
        #100;
        write_enable = 0;
        read_address = 3;
        #100;
        read_select = 1;
        read_address = 0;
        #100;
        read_address = 1;
        #100;
        read_address = 2;
    end
    
endmodule