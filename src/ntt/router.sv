module router #(parameter LOG_CORE_COUNT = 5)(
    input clk,
    input [3:0]log_m,
    input [3:0]log_t,
    input [8:0]address_0,
    input [8:0]address_1,
    input [29:0]in[(1 << LOG_CORE_COUNT) - 1:0][3:0],
    output reg [59:0]loop[(1 << LOG_CORE_COUNT) - 1:0][1:0],
    output reg [8:0]address_loop[1:0],
    output reg [59:0]out[(1 << LOG_CORE_COUNT) - 1:0][1:0],
    output reg [8:0]address_out);

    localparam LOG_N = 12;

    integer k;
    always @(posedge clk) begin
        for (k = 0; k < (1 << LOG_CORE_COUNT); k = k + 1) begin
            /* Third Phase of algorithm. In the last iteration, log_t will be -1, but as it is unsigned, it overflows. This must be the 
            first if statement for it to not becaught in the second if statement. */
            if (log_t == 15) begin
                out[k][0] <= {in[k][1], in[k][0]};
                out[k][1] <= {in[k][3], in[k][2]};
                address_out <= address_0;
            /* First phase of algorithm. Coefficients converge, until all coefficients needed for one part NTT are in one core. */
            end else if (log_t > (LOG_N - (LOG_CORE_COUNT + 2))) begin
                if ((((k << (log_m + 1)) >> LOG_CORE_COUNT) & 1) == 0) begin
                    loop[k][0] <= {in[k][2], in[k][0]};
                    address_loop[0] <= address_0;
                    loop[k][1] <= {in[k + (1 << (1 + log_t + LOG_CORE_COUNT - LOG_N))][2], in[k + (1 << (1 + log_t + LOG_CORE_COUNT - LOG_N))][0]};
                    address_loop[1] <= address_1;
                end else begin
                    loop[k][0] <= {in[k - (1 << (1 + log_t + LOG_CORE_COUNT - LOG_N))][3], in[k - (1 << (1 + log_t + LOG_CORE_COUNT - LOG_N))][1]};
                    address_loop[0] <= address_0;
                    loop[k][1] <= {in[k][3], in[k][1]};
                    address_loop[1] <= address_1;
                end
            end else begin
            /* Second phase of algorithm. Cores work in pairs (every core with index k % 2 == 0 works with k + 1) to avoid memory conflicts 
            and spread the coefficients between them. */
                if (log_t > 0) begin
                    if ((k & 1) == 0) begin
                        if ((address_0 & ((1 << log_t) - 1)) < ((1 << (log_t - 1)))) begin
                            loop[k][0] <= {in[k][2], in[k][0]};
                            address_loop[0] <= address_0;
                            loop[k + 1][0] <= {in[k][3], in[k][1]};
                            address_loop[0] <= address_0;
                        end else begin
                            loop[k][1] <= {in[k][2], in[k][0]};
                            address_loop[1] <= address_0 - (1 << (log_t - 1));
                            loop[k + 1][1] <= {in[k][3], in[k][1]};
                            address_loop[1] <= address_0 - (1 << (log_t - 1));
                        end
                    end else begin
                        if ((address_1 & ((1 << log_t) - 1)) < ((1 << (log_t - 1)))) begin
                            loop[k - 1][0] <= {in[k][2], in[k][0]};
                            address_loop[0] <= address_1 + (1 << (log_t - 1));
                            loop[k][0] <= {in[k][3], in[k][1]};
                            address_loop[0] <= address_1 + (1 << (log_t - 1));
                        end else begin
                            loop[k - 1][1] <= {in[k][2], in[k][0]};
                            address_loop[1] <= address_1;
                            loop[k][1] <= {in[k][3], in[k][1]};
                            address_loop[1] <= address_1;
                        end
                    end
                /* Last movement before output. No inter-core communication is needed. */
                end else if (log_t == 0) begin
                    loop[k][0] <= {in[k][2], in[k][0]};
                    address_loop[0] <= address_0;
                    loop[k][1] <= {in[k][3], in[k][1]};
                    address_loop[1] <= address_1;
                end
            end
        end
    end
    
endmodule