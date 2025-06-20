module ntt_processor_tb();

    localparam LOG_CORE_COUNT = 5;

    reg clk = 0; 
    reg write_enable, start;
    reg [10:0]address_in;
    reg [59:0]data_in;
    wire done;
    wire [59:0]out[(1 << LOG_CORE_COUNT) - 1:0][1:0];
    wire [8:0]address_out;
    
    ntt_processor #(.MOD_INDEX(0), .LOG_CORE_COUNT(LOG_CORE_COUNT)) dut (
        .clk(clk),
        .write_enable(write_enable),
        .start(start),
        .address_in(address_in),
        .data_in(data_in),
        .done(done),
        .out(out),
        .address_out(address_out)
    );
    
    always #50 clk = ~clk;
    
    integer i = 0;
    reg [29:0]upper, lower;
    initial begin
        write_enable = 1;
        #100;
        while (i < 2048) begin
            lower = i;
            upper = 0;
            data_in = {upper, lower};
            address_in = i;
            i = i + 1;
            #100;
        end
        start = 1;
        write_enable = 0;
        #100;
        start = 0;
    end

endmodule