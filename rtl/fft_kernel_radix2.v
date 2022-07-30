module fft_kernel_radix2 #(
    parameter N = 8,
    parameter M = 4
) (
    input  wire               clk_i,
    input  wire               rstn_i,
    input  wire               en_i,
    input  wire signed [15:0] X1_real_i,
    input  wire signed [15:0] X1_imag_i,
    input  wire signed [15:0] X2_real_i,
    input  wire signed [15:0] X2_imag_i,
    output wire               valid_o,
    output wire signed [15:0] X1_real_o,
    output wire signed [15:0] X1_imag_o,
    output wire signed [15:0] X2_real_o,
    output wire signed [15:0] X2_imag_o
);

    localparam WIDTH = $clog2(N);
    localparam R2_BIT = $clog2(M);
    localparam MEM_LEN = M / 2;


    reg [WIDTH-1:0] counter;
    wire [WIDTH:0] counter_next;
    wire [WIDTH-1:0] counter_max;

    reg [WIDTH-2:0] wn_counter;

    reg signed [15:0] mem1_real[MEM_LEN-1:0];
    reg signed [15:0] mem1_imag[MEM_LEN-1:0];

    reg signed [15:0] mem2_real[MEM_LEN-1:0];
    reg signed [15:0] mem2_imag[MEM_LEN-1:0];

    wire signed [17:0] Wn_r[3:0];
    wire signed [17:0] Wn_i[3:0];

    assign Wn_r[0] = 4096;
    assign Wn_r[1] = 2896;
    assign Wn_r[2] = 0;
    assign Wn_r[3] = -2896;

    assign Wn_i[0] = 0;
    assign Wn_i[1] = -2896;
    assign Wn_i[2] = -4096;
    assign Wn_i[3] = -2896;

    wire mem1_select_mem2;
    wire r2_select_mem2;
    wire valid_next;
    generate
        if (M == N) begin : g_r2_0_level
            assign counter_max = N;
            assign mem1_select_mem2 = 0;
            assign r2_select_mem2 = 0;
            assign valid_next = counter >= (N / 2);
        end else begin : g_r2_gt0_level
            assign counter_max = N * 3 / 4;
            assign mem1_select_mem2 = counter[R2_BIT-1] && (counter < N / 2);
            assign r2_select_mem2 = (counter[WIDTH-1:R2_BIT] != 0) && (!counter[R2_BIT-1]);
            assign valid_next = mem1_select_mem2 || r2_select_mem2;
        end
    endgenerate
    assign counter_next = counter + 'd1;

    genvar i;
    generate
        for (i = 0; i < MEM_LEN - 1; i = i + 1) begin : g_mem_link
            always @(posedge clk_i or negedge rstn_i) begin
                if (!rstn_i) begin
                    mem1_real[i] <= 'd0;
                    mem1_imag[i] <= 'd0;
                    mem2_real[i] <= 'd0;
                    mem2_imag[i] <= 'd0;
                end else begin
                    if (en_i || r2_select_mem2) begin
                        mem1_real[i] <= mem1_real[i+1];
                        mem1_imag[i] <= mem1_imag[i+1];
                        mem2_real[i] <= mem2_real[i+1];
                        mem2_imag[i] <= mem2_imag[i+1];
                    end
                end
            end
        end
    endgenerate

    always @(posedge clk_i or negedge rstn_i) begin
        if (!rstn_i) begin
            mem1_real[MEM_LEN-1] <= 'd0;
            mem1_imag[MEM_LEN-1] <= 'd0;
            mem2_real[MEM_LEN-1] <= 'd0;
            mem2_imag[MEM_LEN-1] <= 'd0;
        end else begin
            if (en_i || r2_select_mem2) begin
                mem1_real[MEM_LEN-1] <= mem1_select_mem2 ? mem2_real[0] : X1_real_i;
                mem1_imag[MEM_LEN-1] <= mem1_select_mem2 ? mem2_imag[0] : X1_imag_i;
                mem2_real[MEM_LEN-1] <= X2_real_i;
                mem2_imag[MEM_LEN-1] <= X2_imag_i;
            end
        end
    end

    always @(posedge clk_i or negedge rstn_i) begin
        if (!rstn_i) begin
            wn_counter <= 'd0;
        end else begin
            if (valid_next) begin
                wn_counter <= wn_counter + (N / M);
            end else begin
                wn_counter <= 'd0;
            end
        end
    end

    fft_radix2_dif #(
        .WN_WIDTH(12)
    ) radix2 (
        .clk_i    (clk_i),
        .rst_n_i  (rstn_i),
        .en_i     (valid_next),
        .x1_real_i(mem1_real[0]),
        .x1_imag_i(mem1_imag[0]),
        .x2_real_i(r2_select_mem2 ? mem2_real[0] : X1_real_i),
        .x2_imag_i(r2_select_mem2 ? mem2_imag[0] : X1_imag_i),
        .w_real_i (Wn_r[wn_counter]),
        .w_imag_i (Wn_i[wn_counter]),
        .valid_o  (valid_o),
        .X1_real_o(X1_real_o),
        .X1_imag_o(X1_imag_o),
        .X2_real_o(X2_real_o),
        .X2_imag_o(X2_imag_o),
        .overflow ()
    );

    always @(posedge clk_i or negedge rstn_i) begin
        if (!rstn_i) begin
            counter <= 'd0;
        end else begin
            if (counter_next == counter_max) begin
                counter <= 'd0;
            end else if (en_i || r2_select_mem2) begin
                counter <= counter_next;
            end
        end
    end

    // always @(posedge clk_i or negedge rstn_i) begin
    //     if (!rstn_i) begin
    //         X1_real_o <= 'd0;
    //         X1_imag_o <= 'd0;
    //         X2_real_o <= 'd0;
    //         X2_imag_o <= 'd0;
    //         valid_o   <= 'd0;
    //     end else begin
    //         if (valid_next) begin
    //             X1_real_o <= mem1_real[0];
    //             X1_imag_o <= mem1_imag[0];
    //             X2_real_o <= r2_select_mem2 ? mem2_real[0] : X1_real_i;
    //             X2_imag_o <= r2_select_mem2 ? mem2_imag[0] : X1_imag_i;
    //         end
    //         valid_o   <= valid_next;
    //     end
    // end
endmodule
