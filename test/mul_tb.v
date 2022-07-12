module mul_tb;
    initial begin
        $dumpfile("mul_tb.vcd");  //生成的vcd文件名称
        $dumpvars(0, mul_tb);  //tb模块名称
        $timeformat(-9, 2, "ns", 4);
    end
    localparam integer T = 10;
    localparam integer DW = 8;

    reg aclk;
    reg aresetn;

    reg [DW-1:0] a;
    reg [DW-1:0] b;
    wire [DW*2-1:0] c;

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
    integer _a, _b;
    initial begin
        _a = 0;
        _b = 0;
        a = 0;
        b = 0;
        wait (aresetn == 1);
        for (i = 0; i < 20; i = i + 1) begin
            _a <= $signed(a);
            _b <= $signed(b);
            a <= -$random();
            b <= $random();
            aclk_wait(1);
            $display("%0d * %0d => %0d", _a, _b, $signed(c));
        end
    end

    mul #(
        .WIDTH(DW),
        .PIPELINE(7)
    ) mul_u0 (
        .clk_i(aclk),
        .rst_n_i(aresetn),
        .a_i(a),
        .b_i(b),
        .c_o(c)
    );

endmodule
