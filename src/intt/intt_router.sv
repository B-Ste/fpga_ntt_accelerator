`timescale 1ns / 1ps

module intt_router #(parameter LOG_CORE_COUNT = 5) (
    input clk,
    input [3:0]log_m,
    input [3:0]log_t,
    input [8:0]address_in[1:0],
    input [29:0]in[(1 << LOG_CORE_COUNT) - 1:0][3:0],
    output reg [59:0]loop[(1 << LOG_CORE_COUNT) - 1:0][1:0],
    output reg [8:0]address_loop[1:0],
    output reg [59:0]out[(1 << LOG_CORE_COUNT) - 1:0][1:0],
    output reg [8:0]address_out);

    localparam LOG_N = 12;

    integer k;
    always @(posedge clk) begin
        for (k = 0; k < (1 << LOG_CORE_COUNT); k = k + 1) begin
            if (log_m == 12) begin
                // First phase: first iteration of computation where custom routing is required
                loop[k][0] <= {in[k][2], in[k][0]};
                loop[k][1] <= {in[k][3], in[k][1]};
                address_loop[0] <= address_in[0];
                address_loop[1] <= address_in[1];
            end else if (log_t < (LOG_N - (LOG_CORE_COUNT + 2))) begin
                // Second phase 
                if ((k & 1) == 0) begin
                    if ((address_in[0] & ((1 << (log_t + 1)) - 1)) < (1 << log_t)) begin
                        loop[k][0] <= {in[k + 1][0], in[k][0]};
                        loop[k][1] <= {in[k + 1][1], in[k][1]};
                        address_loop[0] <= address_in[0];
                    end else begin
                        loop[k + 1][0] <= {in[k + 1][0], in[k][0]};
                        loop[k + 1][1] <= {in[k + 1][1], in[k][1]};
                        address_loop[1] <= address_in[0] - (1 << log_t);
                    end
                end else begin
                    if ((address_in[1] & ((1 << (log_t + 1)) - 1)) < (1 << log_t)) begin
                        loop[k - 1][0] <= {in[k][2], in[k - 1][2]};
                        loop[k - 1][1] <= {in[k][3], in[k - 1][3]};
                        address_loop[0] <= address_in[1] + (1 << log_t);
                    end else begin
                        loop[k][0] <= {in[k][2], in[k - 1][2]};
                        loop[k][1] <= {in[k][3], in[k - 1][3]};
                        address_loop[1] <= address_in[1];
                    end
                end
            end else begin
                // Third phase
                if (log_m != 1) begin
                    // Every iteration of third phase except last
                    if ((((k << log_m) >> (LOG_CORE_COUNT + 1)) & 1) == 0) begin
                        loop[k][0] <= {in[k + ((1 << (log_t + LOG_CORE_COUNT + 2)) >> LOG_N)][0], in[k][0]};
                        loop[k][1] <= {in[k + ((1 << (log_t + LOG_CORE_COUNT + 2)) >> LOG_N)][1], in[k][1]};
                    end else begin 
                        loop[k][0] <= {in[k][2], in[k - ((1 << (log_t + LOG_CORE_COUNT + 2)) >> LOG_N)][2]};
                        loop[k][1] <= {in[k][3], in[k - ((1 << (log_t + LOG_CORE_COUNT + 2)) >> LOG_N)][3]};                        
                    end
                    address_loop[0] <= address_in[0];
                    address_loop[1] <= address_in[1];
                end else begin
                    // after last iteration of third phase, output computed coefficients 
                    out[k][0] <= {in[k][1], in[k][0]};
                    out[k][1] <= {in[k][3], in[k][2]};
                    address_out <= address_in[0];
                end
            end
        end
    end
endmodule
