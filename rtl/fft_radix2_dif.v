module fft_radix2_dif #(
    parameter WIDTH = 16,
    parameter WN_WIDTH = 10
) (
    input  wire                    clk_i,
    input  wire                    rst_n_i,
    input  wire                    en_i,
    input  wire signed [WIDTH-1:0] x1_real_i,
    input  wire signed [WIDTH-1:0] x1_imag_i,
    input  wire signed [WIDTH-1:0] x2_real_i,
    input  wire signed [WIDTH-1:0] x2_imag_i,
    input  wire signed [WIDTH-1:0] w_real_i,
    input  wire signed [WIDTH-1:0] w_imag_i,
    output wire signed [  WIDTH:0] X1_real_o,
    output wire signed [  WIDTH:0] X1_imag_o,
    output reg signed  [  WIDTH:0] X2_real_o,
    output reg signed  [  WIDTH:0] X2_imag_o,
    output wire                    valid_o,
    output reg         [      3:0] overflow
);

    localparam integer IP_WIDTH = 18;

    wire signed [IP_WIDTH*2-1:0] mul_x2_w_r_o;
    wire signed [IP_WIDTH*2-1:0] mul_x2_w_i_o;

    wire signed [IP_WIDTH*2-WN_WIDTH-1:0] mul_x2_w_r_round;
    wire signed [IP_WIDTH*2-WN_WIDTH-1:0] mul_x2_w_i_round;

    wire signed [IP_WIDTH-1:0] x1_real;
    wire signed [IP_WIDTH-1:0] x1_imag;
    wire signed [IP_WIDTH-1:0] x2_real;
    wire signed [IP_WIDTH-1:0] x2_imag;

    wire signed [IP_WIDTH-1:0] X1_real;
    wire signed [IP_WIDTH-1:0] X1_imag;
    wire signed [IP_WIDTH-1:0] X2_real;
    wire signed [IP_WIDTH-1:0] X2_imag;

    wire signed [IP_WIDTH-1:0] Wn_real;
    wire signed [IP_WIDTH-1:0] Wn_imag;

    localparam DELAY = 5;
    reg  [WIDTH-1:0] X1_real_buf[DELAY-1:0];
    reg  [WIDTH-1:0] X1_imag_buf[DELAY-1:0];
    reg  [DELAY-1:0] valid_buf;

    wire [  WIDTH:0] half_wn;
    assign half_wn = (1 << WN_WIDTH) >> 1;
    assign mul_x2_w_r_round = (mul_x2_w_r_o + half_wn) >> WN_WIDTH;
    assign mul_x2_w_i_round = (mul_x2_w_i_o + half_wn) >> WN_WIDTH;

    assign x1_real = x1_real_i;
    assign x1_imag = x1_imag_i;

    assign x2_real = x2_real_i;
    assign x2_imag = x2_imag_i;

    assign Wn_real = w_real_i;
    assign Wn_imag = w_imag_i;

    assign X1_real = x1_real + x2_real;
    assign X1_imag = x1_imag + x2_imag;

    assign X2_real = x1_real - x2_real;
    assign X2_imag = x1_imag - x2_imag;

    complex_mul cpx_mul_inst (
        .clock(clk_i),
        .aclr(!rst_n_i),
        .ena(1'b1),
        .dataa_imag(en_i ? X2_imag : 'd0),
        .dataa_real(en_i ? X2_real : 'd0),
        .datab_imag(Wn_imag),
        .datab_real(Wn_real),
        .result_imag(mul_x2_w_i_o),
        .result_real(mul_x2_w_r_o)
    );

    always @(posedge clk_i or negedge rst_n_i) begin
        if (!rst_n_i) begin
            X2_real_o <= 'd0;
            X2_imag_o <= 'd0;
            overflow  <= 'd0;
        end else begin
            if (valid_buf[DELAY-2]) begin
                X2_real_o <= {
                    mul_x2_w_r_round[IP_WIDTH*2-WN_WIDTH-1],
                    mul_x2_w_r_round[IP_WIDTH*2-WN_WIDTH-1:1]
                };
                X2_imag_o <= {
                    mul_x2_w_i_round[IP_WIDTH*2-WN_WIDTH-1],
                    mul_x2_w_i_round[IP_WIDTH*2-WN_WIDTH-1:1]
                };
                // overflow[0] <= result_X1_real[WIDTH+1] ^ result_X1_real[WIDTH];
                // overflow[1] <= result_X1_imag[WIDTH+1] ^ result_X1_imag[WIDTH];
                // overflow[2] <= result_X2_real[WIDTH+1] ^ result_X2_real[WIDTH];
                // overflow[3] <= result_X2_imag[WIDTH+1] ^ result_X2_imag[WIDTH];
            end
        end
    end


    genvar i;
    generate
        for (i = 1; i < DELAY; i = i + 1) begin : g_gen_x1_buf
            always @(posedge clk_i or negedge rst_n_i) begin
                if (!rst_n_i) begin
                    X1_real_buf[i] <= 'd0;
                    X1_imag_buf[i] <= 'd0;
                    valid_buf[i]   <= 'b0;
                end else begin
                    X1_real_buf[i] <= X1_real_buf[i-1];
                    X1_imag_buf[i] <= X1_imag_buf[i-1];
                    valid_buf[i]   <= valid_buf[i-1];
                end
            end
        end
    endgenerate
    always @(posedge clk_i or negedge rst_n_i) begin
        if (!rst_n_i) begin
            X1_real_buf[0] <= 'd0;
            X1_imag_buf[0] <= 'd0;
            valid_buf[0]   <= 'd0;
        end else begin
            X1_real_buf[0] <= X1_real >> 1;
            X1_imag_buf[0] <= X1_imag >> 1;
            valid_buf[0]   <= en_i;
        end
    end

    assign X1_real_o = X1_real_buf[DELAY-1];
    assign X1_imag_o = X1_imag_buf[DELAY-1];
    assign valid_o   = valid_buf[DELAY-1];

endmodule
