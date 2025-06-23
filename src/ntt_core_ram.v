module ntt_core_ram #(
    parameter LOG_CORE_COUNT = 5) (
    input clk,
    input write_select,
    input write_enable,
    input read_select,
    input [((LOG_N - (LOG_CORE_COUNT + 2))) - 1:0]write_address,
    input [59:0]data_in,
    input [(LOG_N - (LOG_CORE_COUNT + 2)) - 1:0]read_address,
    output reg [59:0]data_out);

    localparam LOG_N = 12;
    localparam HEIGHT = 1 << (LOG_N - (LOG_CORE_COUNT + 2));

    reg [59:0]memory[HEIGHT - 1:0][1:0];

    integer i;
    initial begin
        for (i = 0; i < HEIGHT; i = i + 1) begin
            memory[i][0] <= 0;
            memory[i][1] <= 0;
        end
    end

    always @(posedge clk) begin
        data_out <= memory[read_address][read_select];
        if (write_enable) memory[write_address][write_select] <= data_in;
    end
    
endmodule