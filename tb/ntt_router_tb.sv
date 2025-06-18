`timescale 1ns / 1ps

module ntt_router_tb();

    localparam LOG_CORE_COUNT = 5;

    reg clk = 0;
    reg [3:0]log_m, log_t;
    reg [8:0]address_0, address_1;
    reg [29:0]in[(1 << LOG_CORE_COUNT) - 1: 0][3:0];
    wire [59:0]loop[(1 << LOG_CORE_COUNT) - 1:0][1:0];
    wire [8:0]address_loop[(1 << LOG_CORE_COUNT) - 1:0][1:0];
    wire [59:0]out[(1 << LOG_CORE_COUNT) - 1:0][1:0];
    wire [8:0]address_out[(1 << LOG_CORE_COUNT) - 1:0];

    router #LOG_CORE_COUNT dut (
        .clk(clk),
        .log_m(log_m),
        .log_t(log_t),
        .address_0(address_0),
        .address_1(address_1),
        .in(in),
        .loop(loop),
        .address_loop(address_loop),
        .out(out),
        .address_out(address_out)
    );

    always #50 clk = ~clk;

    integer fd_loop;
    integer i;
    initial begin
        fd_loop = $fopen("loop.txt", "w");

        log_m = 11;
        log_t = -1;
        address_0 = 10;
        address_1 = 10;
        for (i = 0; i < (1 << LOG_CORE_COUNT); i = i + 1) begin
            in[i][0] = 4 * i;
            in[i][1] = 4 * i + 1;
            in[i][2] = 4 * i + 2;
            in[i][3] = 4 * i + 3;
        end

        #100;
        
        /*
        for (i = 0; i < (1 << LOG_CORE_COUNT); i = i + 1) begin
            $fdisplay(fd_loop, loop[i][0][29:0]);
            $fdisplay(fd_loop, loop[i][0][59:30]);
            $fdisplay(fd_loop, address_loop[i][0]);
            $fdisplay(fd_loop, loop[i][1][29:0]);
            $fdisplay(fd_loop, loop[i][1][59:30]);
            $fdisplay(fd_loop, address_loop[i][1]);
        end
        */

        for (i = 0; i < (1 << LOG_CORE_COUNT); i = i + 1) begin
            $fdisplay(fd_loop, out[i][0][29:0]);
            $fdisplay(fd_loop, out[i][0][59:30]);
            $fdisplay(fd_loop, address_out[i]);
            $fdisplay(fd_loop, out[i][1][29:0]);
            $fdisplay(fd_loop, out[i][1][59:30]);
            $fdisplay(fd_loop, address_out[i]);
        end

        $fclose(fd_loop);
    end

endmodule
