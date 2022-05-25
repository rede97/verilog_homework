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

    reset_synchronizer dut (
        .clk_i(clk),
        .rstn_unsync_i(async_rst_n),
        .rstn_sync_o(sync_rst_n)
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
