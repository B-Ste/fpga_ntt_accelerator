`timescale 1ns / 1ps

module nwc_processor_tb();

    reg clk = 0;
    reg [59:0]data_in0, data_in1;
    reg write_enable, start;
    wire [59:0]data_out;
    wire output_active;

    nwc_processor dut (
        .clk(clk),
        .data_in0(data_in0),
        .data_in1(data_in1),
        .write_enable(write_enable),
        .start(start),
        .data_out(data_out),
        .output_active(output_active)
    );

    always #50 clk = ~clk;

    integer i;
    integer fd_in1;
    integer fd_in2;
    integer fd_out;
    reg [59:0]input_coe0, input_coe1;
    initial begin
        fd_out = $fopen("output_processor.txt", "w");
        fd_in1 = $fopen("input1.txt", "r");
        fd_in2 = $fopen("input2.txt", "r");
        #100;
        $fclose(fd_out);
        write_enable = 1;
        for (i = 0; i < 2048; i = i + 1) begin
            $fscanf(fd_in1, "%0d", input_coe0);
            $fscanf(fd_in2, "%0d", input_coe1);
            data_in0 = input_coe0;
            data_in1 = input_coe1;
            #100;
        end
        write_enable = 0;
        start = 1;
        #100;
        start = 0;
        $fclose(fd_in1);
        $fclose(fd_in2);
    end

    always @(posedge clk) begin
        if (output_active) begin
            fd_out = $fopen("output_processor.txt", "a");
            $fdisplay(fd_out, data_out[29:0]);
            $fdisplay(fd_out, data_out[59:30]);
            $fclose(fd_out);
        end
    end

endmodule
