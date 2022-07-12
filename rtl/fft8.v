module fft8 (
    input  wire        clk_i,
    input  wire        rst_n_i,
    input  wire [15:0] x0_i,
    input  wire [15:0] x1_i,
    input  wire [15:0] x2_i,
    input  wire [15:0] x3_i,
    input  wire [15:0] x4_i,
    input  wire [15:0] x5_i,
    input  wire [15:0] x6_i,
    input  wire [15:0] x7_i,
    output wire [15:0] X0_r_o,
    output wire [15:0] X0_i_o,
    output wire [15:0] X1_r_o,
    output wire [15:0] X1_i_o,
    output wire [15:0] X2_r_o,
    output wire [15:0] X2_i_o,
    output wire [15:0] X3_r_o,
    output wire [15:0] X3_i_o,
    output wire [15:0] X4_r_o,
    output wire [15:0] X4_i_o,
    output wire [15:0] X5_r_o,
    output wire [15:0] X5_i_o,
    output wire [15:0] X6_r_o,
    output wire [15:0] X6_i_o,
    output wire [15:0] X7_r_o,
    output wire [15:0] X7_i_o
);

    wire [17:0] x[7:0];
    wire [18:0] r_link_stage_0_o[7:0];
    wire [18:0] i_link_stage_0_o[7:0];
    wire [18:0] r_link_stage_1_o[7:0];
    wire [18:0] i_link_stage_1_o[7:0];
    wire [18:0] r_link_stage_2_o[7:0];
    wire [18:0] i_link_stage_2_o[7:0];

    // wire [17:0] r_link_stage_1_i[7:0];
    // wire [17:0] i_link_stage_1_i[7:0];

    assign x[0]   = {{x0_i[15]}, {x0_i[15]}, x0_i};
    assign x[1]   = {{x4_i[15]}, {x4_i[15]}, x4_i};
    assign x[2]   = {{x2_i[15]}, {x2_i[15]}, x2_i};
    assign x[3]   = {{x6_i[15]}, {x6_i[15]}, x6_i};
    assign x[4]   = {{x1_i[15]}, {x1_i[15]}, x1_i};
    assign x[5]   = {{x5_i[15]}, {x5_i[15]}, x5_i};
    assign x[6]   = {{x3_i[15]}, {x3_i[15]}, x3_i};
    assign x[7]   = {{x7_i[15]}, {x7_i[15]}, x7_i};

    assign X0_r_o = r_link_stage_2_o[0];
    assign X0_i_o = i_link_stage_2_o[0];
    assign X1_r_o = r_link_stage_2_o[1];
    assign X1_i_o = i_link_stage_2_o[1];
    assign X2_r_o = r_link_stage_2_o[2];
    assign X2_i_o = i_link_stage_2_o[2];
    assign X3_r_o = r_link_stage_2_o[3];
    assign X3_i_o = i_link_stage_2_o[3];
    assign X4_r_o = r_link_stage_2_o[4];
    assign X4_i_o = i_link_stage_2_o[4];
    assign X5_r_o = r_link_stage_2_o[5];
    assign X5_i_o = i_link_stage_2_o[5];
    assign X6_r_o = r_link_stage_2_o[6];
    assign X6_i_o = i_link_stage_2_o[6];
    assign X7_r_o = r_link_stage_2_o[7];
    assign X7_i_o = i_link_stage_2_o[7];

    localparam integer WN_WIDTH = 12;
    wire [17:0] Wn_r[3:0];
    wire [17:0] Wn_i[3:0];

    assign Wn_r[0] = 4096;
    assign Wn_r[1] = 2896;
    assign Wn_r[2] = 0;
    assign Wn_r[3] = -2896;

    assign Wn_i[0] = 0;
    assign Wn_i[1] = -2896;
    assign Wn_i[2] = -4096;
    assign Wn_i[3] = -2896;

    genvar i, j, k;
    generate
        for (j = 0; j < 4; j = j + 1) begin : g_stage_0
            wire [3:0] overflow_0;
            fft_kernel #(
                .WIDTH(18),
                .WN_WIDTH(WN_WIDTH)
            ) fft_kernel_u (
                .clk_i    (clk_i),
                .rst_n_i  (rst_n_i),
                .x1_real_i(x[j*2]),
                .x1_imag_i(18'd0),
                .x2_real_i(x[j*2+1]),
                .x2_imag_i(18'd0),
                .w_real_i (Wn_r[0]),
                .w_imag_i (Wn_i[0]),
                .X1_real_o(r_link_stage_0_o[j*2]),
                .X1_imag_o(i_link_stage_0_o[j*2]),
                .X2_real_o(r_link_stage_0_o[j*2+1]),
                .X2_imag_o(i_link_stage_0_o[j*2+1]),
                .overflow (overflow_0)
            );
        end
        for (i = 0; i < 2; i = i + 1) begin : g_stage_1
            for (j = 0; j < 2; j = j + 1) begin : g_state_1_
                wire [3:0] overflow_1;
                fft_kernel #(
                    .WIDTH(18),
                    .WN_WIDTH(WN_WIDTH)
                ) fft_kernel_u (
                    .clk_i    (clk_i),
                    .rst_n_i  (rst_n_i),
                    .x1_real_i(r_link_stage_0_o[i*4+j][17:0]),
                    .x1_imag_i(i_link_stage_0_o[i*4+j][17:0]),
                    .x2_real_i(r_link_stage_0_o[i*4+j+2][17:0]),
                    .x2_imag_i(i_link_stage_0_o[i*4+j+2][17:0]),
                    .w_real_i (Wn_r[j*2]),
                    .w_imag_i (Wn_i[j*2]),
                    .X1_real_o(r_link_stage_1_o[i*4+j]),
                    .X1_imag_o(i_link_stage_1_o[i*4+j]),
                    .X2_real_o(r_link_stage_1_o[i*4+j+2]),
                    .X2_imag_o(i_link_stage_1_o[i*4+j+2]),
                    .overflow (overflow_1)
                );
            end
        end


        for (i = 0; i < 4; i = i + 1) begin : g_stage_2
            wire [3:0] overflow_2;
            fft_kernel #(
                .WIDTH(18),
                .WN_WIDTH(WN_WIDTH)
            ) fft_kernel_u (
                .clk_i    (clk_i),
                .rst_n_i  (rst_n_i),
                .x1_real_i(r_link_stage_1_o[i][17:0]),
                .x1_imag_i(i_link_stage_1_o[i][17:0]),
                .x2_real_i(r_link_stage_1_o[i+4][17:0]),
                .x2_imag_i(i_link_stage_1_o[i+4][17:0]),
                .w_real_i (Wn_r[i]),
                .w_imag_i (Wn_i[i]),
                .X1_real_o(r_link_stage_2_o[i]),
                .X1_imag_o(i_link_stage_2_o[i]),
                .X2_real_o(r_link_stage_2_o[i+4]),
                .X2_imag_o(i_link_stage_2_o[i+4]),
                .overflow (overflow_2)
            );
        end
    endgenerate
endmodule
