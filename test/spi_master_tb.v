module spi_master_tb;
    reg         clk;
    reg         rst_n;

    reg         spi_clk_div_vld;
    reg  [ 7:0] spi_clk_div;

    reg  [31:0] stream_data_tx;
    reg         stream_data_tx_vld;
    wire        stream_data_tx_rdy;

    wire        spi_clk;
    reg         spi_sdi;
    wire        spi_sdo;
    wire        spi_cs_n;
    wire        eot;

    wire [31:0] spi_data_rx;
    reg         spi_data_rx_rdy;
    wire        spi_data_rx_vld;

    spi_master_controller spi_master_dut (
        .clk_i               (clk),
        .rst_n_i             (rst_n),
        .spi_clk_div_i       (spi_clk_div),
        .spi_clk_div_vld_i   (spi_clk_div_vld),
        .stream_data_tx_i    (stream_data_tx),
        .stream_data_tx_vld_i(stream_data_tx_vld),
        .stream_data_tx_rdy_o(stream_data_tx_rdy),
        .stream_data_rx_o    (spi_data_rx),
        .stream_data_rx_vld_o(spi_data_rx_vld),
        .stream_data_rx_rdy_i(spi_data_rx_rdy),
        .spi_clk_o           (spi_clk),
        .spi_cs_n_o          (spi_cs_n),
        .spi_sdo_o           (spi_sdo),
        .spi_sdi_i           (spi_sdi),
        .eot_o               (eot)
    );

    initial begin
        clk = 0;
        forever begin
            #5 clk = ~clk;
        end
    end

    task clk_wait(input integer n);
        begin
            repeat (n) begin
                @(posedge clk);
            end
            #1;
        end
    endtask

    initial begin
        spi_clk_div = 4;
        spi_clk_div_vld = 1;
        rst_n = 0;
        clk_wait(5);
        rst_n = 1;
    end

    initial begin
        spi_sdi = 0;
        stream_data_tx = 0;
        stream_data_tx_vld = 0;
        spi_data_rx_rdy = 0;
        wait (rst_n == 1);
        stream_data_tx = {4'b1010, 4'b1011, 8'b00010000, 16'ha001};
        stream_data_tx_vld = 1;
        while (!eot) begin
            clk_wait(1);
        end
        stream_data_tx_vld = 0;
        clk_wait(20);

        stream_data_tx_vld = 1;
        spi_data_rx_rdy = 1;
        stream_data_tx = {4'b1011, 4'b1011, 8'b00010000, 16'h1515};
        wait (spi_master_tb.spi_master_dut.spi_rx_en == 1);
        repeat (16) begin
            @(negedge spi_clk) begin
                spi_sdi = $random;
            end
        end
        stream_data_tx_vld = 0;
        spi_data_rx_rdy = 0;
        spi_data_rx_rdy = 0;
        clk_wait(20);
        $display("Read 0x%08x", spi_data_rx);
        $finish;
    end
endmodule
