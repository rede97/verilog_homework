module reset_synchronizer_tb;
    reg  clk;
    reg  async_rst_n;
    wire sync_rst_n;

    initial begin
        clk = 0;
        forever begin
            #10 clk = ~clk;
        end
    end

    reset_synchronize dut (
        .clk(clk),
        .reset_async(async_rst_n),
        .reset_sync(sync_rst_n)
    );

    initial begin
        async_rst_n = 0;
        #44;
        async_rst_n = 1;
        #30;
        async_rst_n = 0;
        #50;
        async_rst_n = 1;
        #100;
        async_rst_n = 0;
        #1;
        async_rst_n = 1;
        #100;

        $finish;
    end

endmodule
