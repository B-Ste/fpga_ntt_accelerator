`timescale 1ns / 1ps

module intt_processor_tb();

    localparam LOG_CORE_COUNT = 4;
    localparam LOG_N = 12;

    reg clk = 0;
    reg start;
    reg [59:0]data_in[(1 << LOG_CORE_COUNT) - 1:0][1:0];
    wire [59:0]out[(1 << LOG_CORE_COUNT) - 1:0][1:0];
    wire [8:0]address_out;
    wire output_active;

    intt_processor #(.MOD_INDEX(0), .LOG_CORE_COUNT(LOG_CORE_COUNT)) dut (
        .clk(clk),
        .start(start),
        .data_in(data_in),
        .out(out),
        .address_out(address_out),
        .output_active(output_active)
    );

    always #50 clk = ~clk;

    integer i;
    integer k;
    integer fd_out;
    integer fd_in;
    reg [59:0]input_coe0, input_coe1;
    initial begin
        fd_out = $fopen("output_processor.txt", "w");
        fd_in = $fopen("input.txt", "r");
        #100;
        start = 1;
        #100;
        for (i = 0; i < (1 << (LOG_N - 2 - LOG_CORE_COUNT)); i = i + 1) begin
            for (k = 0; k < (1 << LOG_CORE_COUNT); k = k + 1) begin
                $fscanf(fd_in, "%0d", input_coe0);
                $fscanf(fd_in, "%0d", input_coe1);
                data_in[k][0] = input_coe0;
                data_in[k][1] = input_coe1;
            end
            #100;
        end
        $fclose(fd_out);
        $fclose(fd_in);
        start = 0;
    end

    always @(posedge clk) begin
        if (output_active) begin
            fd_out = $fopen("output_processor.txt", "a");
            for (i = 0; i < (1 << LOG_CORE_COUNT); i = i + 1) begin
                $fdisplay(fd_out, out[i][0][29:0]);
                $fdisplay(fd_out, out[i][0][59:30]);
                $fdisplay(fd_out, out[i][1][29:0]);
                $fdisplay(fd_out, out[i][1][59:30]);
            end
            $fclose(fd_out);
        end
    end

endmodule
