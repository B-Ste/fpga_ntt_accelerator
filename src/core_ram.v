module core_ram #(
    parameter LOG_CORE_COUNT = 5) (
    input clk,
    input write_select,
    input write_enable,
    input read_select,
    input [((LOG_N - (LOG_CORE_COUNT + 2))) - 1:0]write_address,
    input [59:0]data_in,
    input [(LOG_N - (LOG_CORE_COUNT + 2)) - 1:0]read_address,
    output [59:0]data_out);

    localparam LOG_N = 12;
    localparam HEIGHT = 1 << (LOG_N - (LOG_CORE_COUNT + 2));

    (* ram_style = "block" *) reg [59:0]memory_0[HEIGHT - 1:0];
    (* ram_style = "block" *) reg [59:0]memory_1[HEIGHT - 1:0];
    reg [59:0]output_0;
    reg [59:0]output_1;
    reg read_select_pipe;
    wire we_1 = (write_select && write_enable) ? 1 : 0;
    wire we_0 = ((~write_select) && write_enable) ? 1 : 0;

    assign data_out = read_select_pipe ? output_1 : output_0;

    integer i;
    initial begin
        for (i = 0; i < HEIGHT; i = i + 1) begin
            memory_0[i] <= 0;
            memory_1[i] <= 0;
        end
    end

    always @(posedge clk) begin
        read_select_pipe <= read_select;
    end

    always @(posedge clk) begin
        output_0 <= memory_0[read_address];
    end

    always @(posedge clk) begin
        output_1 <= memory_1[read_address];
    end

    always @(posedge clk) begin
        if (we_0) begin 
            memory_0[write_address] <= data_in;
        end
    end

    always @(posedge clk) begin
        if (we_1) begin 
            memory_1[write_address] <= data_in;
        end
    end
    
endmodule