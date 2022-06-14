module axi_crossbar_arbiter_tb;
    initial begin
        $dumpfile("axi_crossbar_arbiter_tb.vcd");  //生成的vcd文件名称
        $dumpvars(0, axi_crossbar_arbiter_tb);  //tb模块名称
        $timeformat(-9, 2, "ns", 4);
    end
    localparam integer T = 10;
    localparam integer AXI_REQUEST_NUM = 4;

    reg                        aclk;
    reg                        aresetn;
    reg  [AXI_REQUEST_NUM-1:0] requests;
    wire [AXI_REQUEST_NUM-1:0] arbiter;

    axi_crossbar_arbiter #(
        .AXI_REQUEST_NUM(AXI_REQUEST_NUM)
    ) dut (
        .ACLK      (aclk),
        .ARESETN   (aresetn),
        .requests_i(requests),
        .arbiter_o (arbiter)
    );

    task axi_wait;
        input integer n;
        begin
            repeat (n) @(posedge aclk);
        end
    endtask

    initial begin
        #0 aclk = 0;
        forever #(T / 2) aclk = ~aclk;
    end

    initial begin
        aresetn  = 0;
        requests = 0;
        axi_wait(4);
        aresetn = 1;
    end

    integer i;
    initial begin
        wait (aresetn == 1);
        axi_wait(1);
        for (i = 0; i < 32; i = i + 1) begin
            requests = $urandom;
            axi_wait(1);
        end
        axi_wait(1);
        $finish;
    end

endmodule
