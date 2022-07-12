module complex_mul #(
    parameter integer WIDTH = 8
) (
    input  wire             clk_i,
    input  wire             rst_n_i,
    input  wire [WIDTH-1:0] a_real_i,
    input  wire [WIDTH-1:0] a_imag_i,
    input  wire [WIDTH-1:0] b_real_i,
    input  wire [WIDTH-1:0] b_imag_i,
    output wire [WIDTH*2:0] c_real_o,
    output wire [WIDTH*2:0] c_imag_o
);

    wire [WIDTH*2-1:0] mul_o_arbr;
    wire [WIDTH*2-1:0] mul_o_aibi;
    wire [WIDTH*2-1:0] mul_o_aibr;
    wire [WIDTH*2-1:0] mul_o_arbi;

    mul #(
        .WIDTH(WIDTH),
        .PIPELINE(1)
    ) mul_arbr (
        .clk_i(clk_i),
        .rst_n_i(rst_n_i),
        .a_i(a_real_i),
        .b_i(b_real_i),
        .c_o(mul_o_arbr)
    );

    mul #(
        .WIDTH(WIDTH),
        .PIPELINE(1)
    ) mul_aibi (
        .clk_i(clk_i),
        .rst_n_i(rst_n_i),
        .a_i(a_imag_i),
        .b_i(b_imag_i),
        .c_o(mul_o_aibi)
    );

    mul #(
        .WIDTH(WIDTH),
        .PIPELINE(1)
    ) mul_aibr (
        .clk_i(clk_i),
        .rst_n_i(rst_n_i),
        .a_i(a_imag_i),
        .b_i(b_real_i),
        .c_o(mul_o_aibr)
    );

    mul #(
        .WIDTH(WIDTH),
        .PIPELINE(1)
    ) mul_arbi (
        .clk_i(clk_i),
        .rst_n_i(rst_n_i),
        .a_i(a_real_i),
        .b_i(b_imag_i),
        .c_o(mul_o_arbi)
    );

    assign c_real_o = mul_o_arbr - mul_o_aibi;
    assign c_imag_o = mul_o_aibr + mul_o_arbi;

endmodule
