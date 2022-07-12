module fft_kernel #(
    parameter WIDTH = 16,
    parameter WN_WIDTH = 10
) (
    input  wire             clk_i,
    input  wire             rst_n_i,
    input  wire [WIDTH-1:0] x1_real_i,
    input  wire [WIDTH-1:0] x1_imag_i,
    input  wire [WIDTH-1:0] x2_real_i,
    input  wire [WIDTH-1:0] x2_imag_i,
    input  wire [WIDTH-1:0] w_real_i,
    input  wire [WIDTH-1:0] w_imag_i,
    output reg  [  WIDTH:0] X1_real_o,
    output reg  [  WIDTH:0] X1_imag_o,
    output reg  [  WIDTH:0] X2_real_o,
    output reg  [  WIDTH:0] X2_imag_o,
    output reg  [      3:0] overflow
);

    wire [WIDTH*2:0] mul_x2_w_r_o;
    wire [WIDTH*2:0] mul_x2_w_i_o;

    wire [WIDTH+1:0] mul_x2_w_r;
    wire [WIDTH+1:0] mul_x2_w_i;

    wire [  WIDTH:0] mul_x2_w_r_round;
    wire [  WIDTH:0] mul_x2_w_i_round;

    wire [  WIDTH:0] half_wn;

    wire [WIDTH+1:0] x1_real;
    wire [WIDTH+1:0] x1_imag;

    wire [WIDTH+1:0] result_X1_real;
    wire [WIDTH+1:0] result_X1_imag;
    wire [WIDTH+1:0] result_X2_real;
    wire [WIDTH+1:0] result_X2_imag;

    assign half_wn = (1 << WN_WIDTH) >> 1;
    assign mul_x2_w_r_round = (mul_x2_w_r_o + half_wn) >> WN_WIDTH;
    assign mul_x2_w_i_round = (mul_x2_w_i_o + half_wn) >> WN_WIDTH;

    assign mul_x2_w_r = {mul_x2_w_r_round[WIDTH], mul_x2_w_r_round};
    assign mul_x2_w_i = {mul_x2_w_i_round[WIDTH], mul_x2_w_i_round};
    assign x1_real = {x1_real_i[WIDTH-1], x1_real_i[WIDTH-1], x1_real_i};
    assign x1_imag = {x1_imag_i[WIDTH-1], x1_imag_i[WIDTH-1], x1_imag_i};

    assign result_X1_real = x1_real + mul_x2_w_r;
    assign result_X1_imag = x1_imag + mul_x2_w_i;

    assign result_X2_real = x1_real - mul_x2_w_r;
    assign result_X2_imag = x1_imag - mul_x2_w_i;

    complex_mul #(
        .WIDTH(WIDTH)
    ) cpx_mul (
        .clk_i   (clk_i),
        .rst_n_i (rst_n_i),
        .a_real_i(x2_real_i),
        .a_imag_i(x2_imag_i),
        .b_real_i(w_real_i),
        .b_imag_i(w_imag_i),
        .c_real_o(mul_x2_w_r_o),
        .c_imag_o(mul_x2_w_i_o)
    );

    always @(posedge clk_i or negedge rst_n_i) begin
        if (!rst_n_i) begin
            X1_real_o <= 'd0;
            X1_imag_o <= 'd0;
            X2_real_o <= 'd0;
            X2_imag_o <= 'd0;
            overflow  <= 'd0;
        end else begin
            X1_real_o   <= result_X1_real >> 1;
            X1_imag_o   <= result_X1_imag >> 1;
            X2_real_o   <= result_X2_real >> 1;
            X2_imag_o   <= result_X2_imag >> 1;
            overflow[0] <= result_X1_real[WIDTH+1] ^ result_X1_real[WIDTH];
            overflow[1] <= result_X1_imag[WIDTH+1] ^ result_X1_imag[WIDTH];
            overflow[2] <= result_X2_real[WIDTH+1] ^ result_X2_real[WIDTH];
            overflow[3] <= result_X2_imag[WIDTH+1] ^ result_X2_imag[WIDTH];
        end
    end



endmodule
