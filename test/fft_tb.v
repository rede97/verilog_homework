module fft_kernel_tb;
    initial begin
        $dumpfile("fft_tb.vcd");  //生成的vcd文件名称
        $dumpvars(0, fft_tb);  //tb模块名称
        $timeformat(-9, 2, "ns", 4);
    end
    localparam integer T = 10;
    localparam integer DW = 16;
    localparam integer WW = 10;

    reg aclk;
    reg aresetn;

    reg [DW-1:0] a_r;
    reg [DW-1:0] a_i;

    reg [DW-1:0] b_r;
    reg [DW-1:0] b_i;

    reg [WW:0] w_r;
    reg [WW:0] w_i;

    wire [DW+1:0] x1_r;
    wire [DW+1:0] x1_i;

    wire [DW+1:0] x2_r;
    wire [DW+1:0] x2_i;

    wire [15:0] X_r[7:0];
    wire [15:0] X_i[7:0];

    initial begin
        #0 aclk = 0;
        forever #(T / 2) aclk = ~aclk;
    end

    task aclk_wait;
        input integer n;
        begin
            repeat (n) @(posedge aclk);
        end
    endtask

    initial begin
        aresetn = 0;
        aclk_wait(5);
        aresetn = 1;
        aclk_wait(1024 * 2);
        $finish;
    end

    integer i;
    initial begin
        aclk_wait(30);
        for (i = 0; i < 8; i = i + 1) begin
            $display("%0d: (%0d + j%0d)", i, X_r[i], X_i[i]);
        end
        $finish;
    end


    fft8 fft_once (
        .clk_i  (aclk),
        .rst_n_i(aresetn),
        .x0_i   (16'd000),
        .x1_i   (16'd100),
        .x2_i   (16'd200),
        .x3_i   (16'd300),
        .x4_i   (16'd400),
        .x5_i   (16'd500),
        .x6_i   (16'd600),
        .x7_i   (16'd700),
        .X0_r_o (X_r[0]),
        .X0_i_o (X_i[0]),
        .X1_r_o (X_r[1]),
        .X1_i_o (X_i[1]),
        .X2_r_o (X_r[2]),
        .X2_i_o (X_i[2]),
        .X3_r_o (X_r[3]),
        .X3_i_o (X_i[3]),
        .X4_r_o (X_r[4]),
        .X4_i_o (X_i[4]),
        .X5_r_o (X_r[5]),
        .X5_i_o (X_i[5]),
        .X6_r_o (X_r[6]),
        .X6_i_o (X_i[6]),
        .X7_r_o (X_r[7]),
        .X7_i_o (X_i[7])
    );


endmodule
